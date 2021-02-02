//
//  PasswordDataModel.swift
//  CryptGuard_iOS
//

import Foundation

struct PasswordData: Identifiable, Encodable, Decodable {
    let id: UUID
    var siteName: String?
    var username: String?
    var email: String?
    var password: String?
    var additionalData: String?
}

var passwordDataLista: [PasswordData] = []
