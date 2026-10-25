import Foundation
import Security

enum PasswordGenerator {
    enum Failure: Error { case invalidOptions, randomSource }
    static func generate(length: Int, uppercase: Bool, lowercase: Bool, digits: Bool, symbols: Bool, excludeAmbiguous: Bool) throws -> String {
        guard (8...64).contains(length) else { throw Failure.invalidOptions }
        var groups = [String]()
        if uppercase { groups.append("ABCDEFGHIJKLMNOPQRSTUVWXYZ") }
        if lowercase { groups.append("abcdefghijklmnopqrstuvwxyz") }
        if digits { groups.append("0123456789") }
        if symbols { groups.append("!@#$%^&*()-_=+[]{}:,.?") }
        if excludeAmbiguous { groups = groups.map { String($0.filter { !"Il1O0o".contains($0) }) } }
        guard !groups.isEmpty else { throw Failure.invalidOptions }
        let alphabet = Array(groups.joined())
        // Reject whole candidates until each selected character class is represented.
        // Byte rejection avoids modulo bias; SecRandomCopyBytes is the random source.
        for _ in 0..<1024 {
            var output = ""
            for _ in 0..<length {
                let ceiling = 256 - (256 % alphabet.count)
                var byte: UInt8 = 0
                repeat {
                    guard SecRandomCopyBytes(kSecRandomDefault, 1, &byte) == errSecSuccess else { throw Failure.randomSource }
                } while Int(byte) >= ceiling
                output.append(alphabet[Int(byte) % alphabet.count])
            }
            if groups.allSatisfy({ group in output.contains { group.contains($0) } }) { return output }
        }
        throw Failure.randomSource
    }
}
