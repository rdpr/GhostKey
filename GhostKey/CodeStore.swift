import Foundation

final class CodeStore {
    private(set) var codes: [String] = []
    private(set) var cleanedChecksum: String = "sha256:"
    private(set) var nextIndex: Int = 0
    var remaining: Int { max(0, codes.count - nextIndex) }
    private let queue = DispatchQueue(label: "codes.store.serial")

    func bootstrapIfNeeded() throws {
        try ensureDir(AppPaths.appSupportDir)
        if !FileManager.default.fileExists(atPath: Preferences.codesURL.path) {
            try "# GhostKey\n".data(using: .utf8)!.write(to: Preferences.codesURL)
        }
        if !FileManager.default.fileExists(atPath: Preferences.indexURL.path) {
            let idx = IndexFile(next_index: 0, codes_checksum: "", updated_at: iso8601Now())
            let data = try JSONEncoder().encode(idx)
            try atomicWrite(data: data, to: Preferences.indexURL)
        }
    }

    func loadAll() {
        queue.sync {
            self.codes = Self.readCodes(url: Preferences.codesURL)
            self.cleanedChecksum = Self.computeChecksum(lines: self.codes)
            let idx = Self.readIndex(url: Preferences.indexURL)
            if idx.codes_checksum != self.cleanedChecksum || idx.next_index > self.codes.count {
                // Clamp on mismatch
                self.nextIndex = min(idx.next_index, self.codes.count)
            } else {
                self.nextIndex = idx.next_index
            }
            // Write back normalized index with current checksum
            self.writeIndex()
        }
    }

    func peekNext() -> String? { queue.sync { nextIndex < codes.count ? codes[nextIndex] : nil } }

    @discardableResult
    func advance() -> Bool {
        queue.sync {
            guard nextIndex < codes.count else { return false }
            nextIndex += 1
            writeIndex()
            return true
        }
    }

    func resetIndex(to value: Int) {
        queue.sync {
            nextIndex = max(0, min(value, codes.count))
            writeIndex()
        }
    }

    private func writeIndex() {
        let idx = IndexFile(next_index: nextIndex, codes_checksum: cleanedChecksum, updated_at: iso8601Now())
        do {
            let data = try JSONEncoder().encode(idx)
            try atomicWrite(data: data, to: Preferences.indexURL)
        } catch {
            NSLog("Failed to write index: \(error)")
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

    private static func computeChecksum(lines: [String]) -> String {
        let joined = lines.joined(separator: "\n")
        return sha256Hex(of: Data(joined.utf8))
    }

    private static func readIndex(url: URL) -> IndexFile {
        guard let data = try? Data(contentsOf: url), let idx = try? JSONDecoder().decode(IndexFile.self, from: data) else {
            return IndexFile(next_index: 0, codes_checksum: "", updated_at: iso8601Now())
        }
        return idx
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
