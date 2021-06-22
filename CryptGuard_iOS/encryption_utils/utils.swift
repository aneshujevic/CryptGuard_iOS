//
//  utils.swift
//  CryptGuard_iOS
//

import Foundation

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
