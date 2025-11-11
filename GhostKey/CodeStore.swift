import Foundation

final class CodeStore {
    private(set) var codes: [String] = []
    var remaining: Int { codes.count }
    private let queue = DispatchQueue(label: "codes.store.serial")

    func bootstrapIfNeeded() throws {
        try ensureDir(AppPaths.appSupportDir)
        if !FileManager.default.fileExists(atPath: Preferences.codesURL.path) {
            try "# GhostKey\n".data(using: .utf8)!.write(to: Preferences.codesURL)
        }
    }

    func loadAll() {
        queue.sync {
            self.codes = Self.readCodes(url: Preferences.codesURL)
        }
    }

    func peekNext() -> String? { queue.sync { codes.first } }

    /// Consumes the next code by deleting it from the file
    @discardableResult
    func consumeNext() -> Bool {
        queue.sync {
            guard !codes.isEmpty else { return false }
            
            // Remove first code from array
            codes.removeFirst()
            
            // Write updated codes back to file
            do {
                try Self.writeCodes(codes: codes, to: Preferences.codesURL)
                return true
            } catch {
                NSLog("Failed to write codes after consumption: \(error)")
                return false
            }
        }
    }

    // Helpers
    private static func readCodes(url: URL) -> [String] {
        guard let raw = try? String(contentsOf: url) else { return [] }
        return raw
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && !$0.starts(with: "#") }
    }
    
    private static func writeCodes(codes: [String], to url: URL) throws {
        let content = codes.joined(separator: "\n") + "\n"
        let data = content.data(using: .utf8) ?? Data()
        try atomicWrite(data: data, to: url)
    }

    // Registration append (atomic)
    func append(code: String) throws {
        var valid = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !valid.isEmpty else { return }
        // Default validation: 6-10 digits
        guard valid.range(of: "^\\d{6,10}$", options: .regularExpression) != nil else {
            throw CodeError.storage("Code must be 6–10 digits")
        }
        let data = (valid + "\n").data(using: .utf8)!
        if let fh = try? FileHandle(forWritingTo: Preferences.codesURL) {
            defer { try? fh.close() }
            try fh.seekToEnd()
            try fh.write(contentsOf: data)
        } else {
            try data.write(to: Preferences.codesURL, options: .atomic)
        }
    }
}