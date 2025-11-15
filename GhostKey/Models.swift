import Foundation
import CryptoKit

enum ColorBand: Int, CaseIterable { case green, yellow, orange, red
    static func from(remaining: Int) -> ColorBand {
        let t = Preferences.thresholds
        if remaining <= t.red { return .red }
        if remaining <= t.orange { return .orange }
        if remaining <= t.yellow { return .yellow }
        return .green
    }
    
    // Image name for the ghost icon
    var imageName: String {
        switch self {
        case .green: return "GreenGhost"
        case .yellow: return "YellowGhost"
        case .orange: return "OrangeGhost"
        case .red: return "RedGhost"
        }
    }
    
    // Legacy emoji property (kept for compatibility, but deprecated)
    var emoji: String { switch self { case .green: return "🟢"; case .yellow: return "🟡"; case .orange: return "🟠"; case .red: return "🔴" } }
    
    func isWorse(than other: ColorBand) -> Bool { self.rawValue > other.rawValue }
}

struct Thresholds: Codable {
    var yellow: Int
    var orange: Int
    var red: Int
}

enum CodeError: Error { case storage(String) }
