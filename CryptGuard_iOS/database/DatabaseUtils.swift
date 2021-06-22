//
//  DatabaseUtils.swift
//  CryptGuard_iOS
//

import Foundation
import SwiftUI

func saveChangesToUserDefaults(passwordList: [String]?) {
    UserDefaults.standard.setValue(try! PropertyListEncoder().encode(passwordList), forKey: "pdlist")
}

func deleteDatabaseUserDefaults() {
    UserDefaults.standard.removeObject(forKey: "pdlist")
}

func reEncryptDatabase(databasePassword: String, newDbPassword: String) -> Bool{
    if let data = UserDefaults.standard.value(forKey: "pdlist") as? Data {
        let encryptedPasswordDataList = try! PropertyListDecoder().decode(Array<String>.self, from: data)
        if encryptedPasswordDataList.count != 0 {
            let encrypter = Encrypter()
            
            let newEncryptedPdList = encryptedPasswordDataList.map({ (encryptedpasswordData) -> String in
                let decrypted = try! encrypter.decryptBase64String(inputString: encryptedpasswordData, password: databasePassword)
                return encrypter.encryptStringAndGetBase64(inputString: decrypted, password: newDbPassword)
            })
            
            saveChangesToUserDefaults(passwordList: newEncryptedPdList)
            return true
        }
    }
    return false
}

func createDatabaseDocument() -> EncryptedDocument? {
    if let data = UserDefaults.standard.value(forKey: "pdlist") as? Data {
        let encryptedPasswordDataList = try! PropertyListDecoder().decode(Array<String>.self, from: data)
        if encryptedPasswordDataList.count != 0 {
            var databaseString = ""
            
            for item in encryptedPasswordDataList.enumerated() {
                databaseString.append("\(String(item.offset)),\(item.element.replacingOccurrences(of: "\n", with: "."))\n")
            }
            
            return EncryptedDocument(data: Data(databaseString.bytes))
        }
    }
    return nil
}
