//
//  Encrypter.swift
//  CryptGuard_iOS
//

import Foundation
import CryptoSwift

class Encrypter {
    private let ITERATION_COUNT = 500
    private let AES_KEY_LEN = 256

    // Encrypt the data from stream, encode it to base64 and append salt and iv to it (base64 too)
    func encryptStreamAndGetBase64(inputStream: InputStream, password: String) -> String {
        let byteCount = 16
        var passwordSalt = [UInt8](repeating: 0, count: byteCount)
        
        let status = SecRandomCopyBytes(kSecRandomDefault, byteCount, &passwordSalt)
        
        if status == errSecSuccess {
            do {
                let key: Array<UInt8> = try PKCS5.PBKDF2(password: Array(password.utf8), salt: passwordSalt, iterations: ITERATION_COUNT, keyLength: 32, variant: .sha512).calculate()
                
                let iv = AES.randomIV(AES.blockSize)
                
                let gcm = GCM(iv: iv, mode: .combined)
                
                let aes = try AES(key: key, blockMode: gcm, padding: .noPadding)
                
                let inputData = try Data(reading: inputStream)
                
                let encryptedBytes = try aes.encrypt(inputData.bytes)
                let result = Data(encryptedBytes)
                
                return appendCipherDataToBase64(cipherText: result, passwordSalt: passwordSalt, initVector: iv)
            } catch {
                print(error.localizedDescription)
            }
        }
        return ""
    }

    func decryptStream(inputStream: InputStream, password: String) throws -> String {
        do {
            let encryptedData = try Data(reading: inputStream)
            let cipherData = String(decoding: encryptedData, as: UTF8.self)
            let cipherText = cipherData.split(separator: "\n")[0]
            let passwordSalt = [UInt8](base64: String(cipherData.split(separator: "\n")[1]))
            let initVector = [UInt8](base64:String(cipherData.split(separator: "\n")[2]))
            
            let key: Array<UInt8> = try PKCS5.PBKDF2(password: Array(password.utf8), salt: passwordSalt, iterations: ITERATION_COUNT, keyLength: 32, variant: .sha512).calculate()
            
            let gcm = GCM(iv: initVector, mode: .combined)
            
            let aes = try AES(key: key, blockMode: gcm, padding: .noPadding)
            
            let decryptedBytes = try aes.decrypt([UInt8](base64:String(cipherText)))
            
            return String(bytes: decryptedBytes, encoding: .utf8)!
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }

    func encryptStringAndGetBase64(inputString: String, password: String) -> String {
        let byteCount = 16
        var passwordSalt = [UInt8](repeating: 0, count: byteCount)
        
        let status = SecRandomCopyBytes(kSecRandomDefault, byteCount, &passwordSalt)
        
        if status == errSecSuccess {
            do {
                let key: Array<UInt8> = try PKCS5.PBKDF2(password: Array(password.utf8), salt: passwordSalt, iterations: ITERATION_COUNT, keyLength: 32, variant: .sha512).calculate()
                
                let iv = AES.randomIV(AES.blockSize)
                
                let gcm = GCM(iv: iv, mode: .combined)
                
                let aes = try AES(key: key, blockMode: gcm, padding: .noPadding)
                                
                let encryptedBytes = try aes.encrypt(inputString.bytes)
                let result = Data(encryptedBytes)
                
                return appendCipherDataToBase64(cipherText: result, passwordSalt: passwordSalt, initVector: iv)
            } catch {
                print(error.localizedDescription)
            }
        }
        return ""
    }

    func decryptBase64String(inputString: String, password: String) throws -> String {
        do {
            let cipherText = inputString.split(separator: "\n")[0]
            let passwordSalt = [UInt8](base64: String(inputString.split(separator: "\n")[1]))
            let initVector = [UInt8](base64:String(inputString.split(separator: "\n")[2]))
            
            let key: Array<UInt8> = try PKCS5.PBKDF2(password: Array(password.utf8), salt: passwordSalt, iterations: ITERATION_COUNT, keyLength: 32, variant: .sha512).calculate()
            
            let gcm = GCM(iv: initVector, mode: .combined)
            
            let aes = try AES(key: key, blockMode: gcm, padding: .noPadding)
            let cipherTextStringBase64 = String(cipherText)
            let byteArrayBase64 = [UInt8](base64:cipherTextStringBase64)
            let decryptedBytes = try aes.decrypt(byteArrayBase64)
            
            return String(bytes: decryptedBytes, encoding: .utf8)!
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }

    private func appendCipherDataToBase64(
        cipherText: Data,
        passwordSalt: Array<UInt8>,
        initVector: Array<UInt8>
    ) -> String {
        var cipherTextBase64 = cipherText.base64EncodedString()
        var passwordSaltBase64 = passwordSalt.toBase64()
        var initVectorBase64 = initVector.toBase64()
        cipherTextBase64.append("\n")
        passwordSaltBase64?.append("\n")
        initVectorBase64?.append("\n")
        
        var cipherData: String = ""
        cipherData.append(cipherTextBase64)
        cipherData.append(passwordSaltBase64!)
        cipherData.append(initVectorBase64!)
        
        return cipherData
    }
}

extension Data {
    init(reading input: InputStream) throws {
        self.init()
        input.open()
        defer {
            input.close()
        }

        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                //Stream error occured
                throw input.streamError!
            } else if read == 0 {
                //EOF
                break
            }
            self.append(buffer, count: read)
        }
    }
}

func validatePassphrase(_ passphrase: String) -> Bool {
    let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
    return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: passphrase)
}

func decryptPasswordData(_ str: String, _ password: String) -> PasswordData {
    let encrypter = Encrypter()
    let decryptedJSONPd = try! encrypter.decryptBase64String(inputString: str, password: password)
    let jsonEncoder = JSONDecoder()
    return try! jsonEncoder.decode(PasswordData.self, from: Data(decryptedJSONPd.utf8))
}
