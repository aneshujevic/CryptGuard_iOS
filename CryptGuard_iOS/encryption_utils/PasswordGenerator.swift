//
//  PasswordGenerator.swift
//  CryptGuard_iOS
//

import Foundation
import Security

class PasswordGenerator {
    private var lowerCase = "abcdefghijklmnopqrstuvwxyz"
    private var uppercase =  "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    private var digits = "0123456789"
    private var other = "!\"#$%&'()*+,-./:;<=>[]^_{|}~"
    
    private func generateRandomNumber(bound: Int) -> Int {
        let byteCount = 4
        var randomNumber: Int = 0
        var randomBytes = [UInt8](repeating: 0, count: byteCount)
        
        let status = SecRandomCopyBytes(kSecRandomDefault, byteCount, &randomBytes)
        
        if status == errSecSuccess {
            for byte in randomBytes {
                randomNumber += Int(byte)
            }
            return randomNumber % bound
        }
        
        return 0
    }
        
    private func shuffle(_ s: String) -> String {
        var n = s.count
        var newString = Array(s)
        var source: Int
        
        while (n > 1) {
            source = generateRandomNumber(bound: n)
            n -= 1
            newString.swapAt(source, n)
        }

        return String(newString)
    }

    
    func generate(_ passwordLength: Int) -> String {
        let charsets = Array(arrayLiteral: lowerCase, uppercase, digits, other)
        var password = String()
        var charsetIndex: Int
        var charIndexInt: Int
        var char: Character
        var charIndex: String.Index
        
        for _ in 0..<passwordLength {
            charsetIndex = generateRandomNumber(bound: charsets.count)
            charIndexInt = generateRandomNumber(bound: charsets[charsetIndex].count)
            charIndex = charsets[charsetIndex].index(charsets[charsetIndex].startIndex, offsetBy: charIndexInt)
            char = charsets[charsetIndex][charIndex]
            password.append(char)
        }

        for _ in 0..<10 {
            password = shuffle(password)
        }
        
        return password
    }
}
