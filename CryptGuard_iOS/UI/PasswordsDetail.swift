//
//  PasswordsDetail.swift
//  CryptGuard_iOS
//


import SwiftUI

struct PasswordsDetail: View {
    let id: Int
    
    var passwordData = passwordDataList[0]
    @State private var siteName = passwordDataList[0].siteName
    @State private var username = passwordDataList[0].username
    @State private var email = passwordDataList[0].email
    @State private var password = passwordDataList[0].password
    @State private var additionalData = passwordDataList[0].additionalData
    
    var body: some View {
        VStack {
            Text("Password data")
                .font(.title)
            Form {
                Section {
                    TextField("Site name", text: $siteName)
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                    TextField("Password", text: $password)
                    TextField("Additional data", text: $additionalData)
                }
                Section {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Save password data")
                    })
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Delete password data")
                    })
                }
            }
        }
    }
}

struct PasswordsDetail_Previews: PreviewProvider {
    static var previews: some View {
        PasswordsDetail(id: 1)
    }
}
