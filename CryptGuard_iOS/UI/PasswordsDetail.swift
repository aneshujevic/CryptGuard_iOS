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
    @State private var itemCopied = ""
    @State private var itemCopiedBool = false
    @State private var isSecuredPassword = false
    
    var body: some View {
        VStack {
            Text("Password data")
                .font(.title)
            
            Form {
                Section {
                    TextField("Site name", text: $siteName)
                        .onLongPressGesture() {                           copyToClipboard(sourceItem: "Site name")
                        }
                    
                    TextField("Username", text: $username)
                        .onLongPressGesture() {
                            copyToClipboard(sourceItem: "Username")
                        }
                    
                    TextField("Email", text: $email)
                        .onLongPressGesture() {
                            copyToClipboard(sourceItem: "Email")
                        }
                    
                    if !isSecuredPassword {
                        HStack {
                            TextField("Password", text: $password)
                                .onTapGesture {
                                    isSecuredPassword = true
                                }
                            Button(action: {
                                copyToClipboard(sourceItem: "Password")
                            }) {
                                Image("article")
                                    .renderingMode(.original)
                            }
                        }
                    } else {
                        HStack {
                            SecureField("Password", text: $password)
                                .onTapGesture {
                                    isSecuredPassword = false
                                }
                            Button(action: {
                                copyToClipboard(sourceItem: "Password")
                            }) {
                                Image("article")
                                    .renderingMode(.original)
                            }
                        }
                    }
                    
                    TextField("Additional data", text: $additionalData)
                        .onLongPressGesture() {
                            copyToClipboard(sourceItem: "Additional data")
                        }
                }
                
                .alert(isPresented: $itemCopiedBool, content: {
                    Alert(title: Text("Operation status"), message: Text(itemCopied + " successfully copied to clipboard"), dismissButton: .default(Text("OK")))
                })
                
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
    
    func copyToClipboard(sourceItem: String) {
        var value: String
        
        switch sourceItem {
        case "Username":
            value = username
            break
        case "Email":
            value = email
            break
        case "Password":
            value = password
            break
        case "Additional data":
            value = additionalData
            break
        case "Site name":
            value = siteName
            break
        default:
            return
        }
        
        UIPasteboard.general.string = value
        itemCopied = sourceItem
        itemCopiedBool = true
    }
}

struct PasswordsDetail_Previews: PreviewProvider {
    static var previews: some View {
        PasswordsDetail(id: 1)
    }
}
