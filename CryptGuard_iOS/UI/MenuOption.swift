//
//  MenuOption.swift
//  CryptGuard_iOS
//


import Foundation
import SwiftUI


struct Option: Identifiable {
    let title: String
    let iconName: String
    let description: String
    let id = UUID()
}

let menuOptions = [
    Option(title: "Passwords", iconName: "article", description: "Passwords you've saved"),
    Option(title: "Database", iconName: "key", description: "Database options"),
    Option(title: "Encrypter", iconName: "lock_circle", description: "File encryption tool"),
    Option(title: "Password generator", iconName: "dice", description: "Password generation tool"),
    Option(title: "Online account", iconName: "cloud_circle", description: "Your online database")
]
