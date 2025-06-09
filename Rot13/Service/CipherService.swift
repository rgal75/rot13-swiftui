import Foundation

class CipherService {
    static func cipher(_ text: String) -> String {
        // Example: ROT13 cipher
        return text.unicodeScalars.map { scalar in
            let a: UInt32, n: UInt32
            switch scalar {
            case "a"..."z": a = 97; n = 26
            case "A"..."Z": a = 65; n = 26
            default: return Character(scalar)
            }
            let value = ((scalar.value - a + 13) % n) + a
            return Character(UnicodeScalar(value)!)
        }.reduce("") { $0 + String($1) }
    }
}
