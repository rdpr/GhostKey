import Foundation
import CryptoKit


enum AppPaths {
static let appSupportDir: URL = {
let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
return base.appendingPathComponent("GhostKey", isDirectory: true)
}()
}


enum Preferences {
private static let defaults = UserDefaults.standard


static func registerDefaults() {
defaults.register(defaults: [
"codesPath": AppPaths.appSupportDir.appendingPathComponent("codes.txt").path,
"indexPath": AppPaths.appSupportDir.appendingPathComponent("index.json").path,
"yellowThreshold": 100,
"orangeThreshold": 40,
"redThreshold": 10,
"pasteMethodType": 0 // 0=clipboard+cmdV, 1=type digits
])
}


static var codesURL: URL {
if let path = defaults.string(forKey: "codesPath"), !path.isEmpty {
return URL(fileURLWithPath: path)
}
return AppPaths.appSupportDir.appendingPathComponent("codes.txt")
}
static var indexURL: URL {
if let path = defaults.string(forKey: "indexPath"), !path.isEmpty {
return URL(fileURLWithPath: path)
}
return AppPaths.appSupportDir.appendingPathComponent("index.json")
}


static var thresholds: (yellow: Int, orange: Int, red: Int) {
(defaults.integer(forKey: "yellowThreshold"), defaults.integer(forKey: "orangeThreshold"), defaults.integer(forKey: "redThreshold"))
}


static var pasteMethodType: Int { defaults.integer(forKey: "pasteMethodType") }
}


extension Thresholds {
static var current: Thresholds { Thresholds(yellow: Preferences.thresholds.yellow, orange: Preferences.thresholds.orange, red: Preferences.thresholds.red) }
}


func sha256Hex(of data: Data) -> String {
let digest = SHA256.hash(data: data)
return "sha256:" + digest.compactMap { String(format: "%02x", $0) }.joined()
}


func iso8601Now() -> String { ISO8601DateFormatter().string(from: Date()) }


func ensureDir(_ url: URL) throws {
try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: [FileAttributeKey.posixPermissions: 0o700])
}


func atomicWrite(data: Data, to url: URL) throws {
let tmp = url.appendingPathExtension("tmp")
try data.write(to: tmp, options: .atomic)
// .atomic already does a temp+rename; do a manual rename for explicitness
try? FileManager.default.removeItem(at: url)
try FileManager.default.moveItem(at: tmp, to: url)
}
