//
//  PasswordsDetail.swift
//  CryptGuard_iOS
//

import SwiftUI

struct PasswordsDetail: View {
    var shouldCreate = false

    @State private var pdCurrent: PasswordData?
    @State private var siteName = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var additionalData = ""
    @State private var itemCopied = ""
    @State private var itemCopiedBool = false
    @State private var isSecuredPassword = true
    @State private var alertCreatedShow = false
    @State private var alertDeletedShow = false
    
    init(id: UUID?) {
        if id == nil {
            shouldCreate = true
            pdCurrent = nil
        } else {
            if let currPD = passwordDataList.first(where: {
                $0.id.uuidString == id!.uuidString
            }) {
                _pdCurrent = State(initialValue: currPD)
                _siteName = State(initialValue: currPD.siteName ?? "")
                _username = State(initialValue: currPD.username ?? "")
                _email = State(initialValue: currPD.email ?? "")
                _password = State(initialValue: currPD.password ?? "")
                _additionalData = State(initialValue: currPD.additionalData ?? "")
            }
        }
    }
    
    var body: some View {
        VStack {
            Text("Password data")
                .font(.title)
            
            Form {
                Section {
                    HStack {
                        TextField("Site name", text: $siteName)
                        Button(action: {
                            copyToClipboard(sourceItem: "Site name")
                        }) {
                            Image("article")
                                .renderingMode(.original)
                        }
                    }
                    
                    HStack {
                        TextField("Username", text: $username)
                        Button(action: {
                            copyToClipboard(sourceItem: "Username")
                        }) {
                            Image("article")
                                .renderingMode(.original)
                        }
                    }
                    
                    HStack {
                        TextField("Email", text: $email)
                        Button(action: {
                            copyToClipboard(sourceItem: "Email")
                        }) {
                            Image("article")
                                .renderingMode(.original)
                        }
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
                    
                    HStack {
                        TextField("Additional data", text: $additionalData)
                        Button(action: {
                            copyToClipboard(sourceItem: "Additional data")
                        }) {
                            Image("article")
                                .renderingMode(.original)
                        }
                    }
                }
                
                .alert(isPresented: $itemCopiedBool, content: {
                    Alert(title: Text("Operation status"), message: Text(itemCopied + " successfully copied to clipboard"), dismissButton: .default(Text("OK")))
                })
                
                Section {
                    Button(action: {
                        if (shouldCreate) {
                            let pd = PasswordData(id: UUID(), siteName: siteName, username: username, email: email, password: password, additionalData: additionalData)
                            passwordDataList.append(pd)
                        } else {
                            let pdIndex = passwordDataList.firstIndex(where: {$0.id == pdCurrent?.id})
                            let pd = PasswordData(id: pdCurrent!.id, siteName: siteName, username: username, email: email, password: password, additionalData: additionalData)
                            passwordDataList[pdIndex!] = pd
                        }
                        
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(passwordDataList), forKey: "pdlist")
                        
                        alertCreatedShow = true
                    }, label: {
                        Text("Save password data")
                    })
                    .alert(isPresented: $alertCreatedShow, content: {
                            Alert(title: Text("Operation status"), message: Text("Password data successfully created."), dismissButton: .default(Text("OK")))})
                    
                    Button(action: {
                        passwordDataList.remove(at: passwordDataList.firstIndex(where: {$0.id == pdCurrent?.id})!)
                        
                        alertDeletedShow = true
                    }, label: {
                        Text("Delete password data")
                            .disabled(shouldCreate)
                    })
                    .alert(isPresented: $alertDeletedShow, content:{
                            Alert(title: Text("Operation status"), message: Text("Password data successfully deleted."), dismissButton: .default(Text("OK")))})
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
        PasswordsDetail(id: nil)
    }
}
