//
//  PasswordsDetail.swift
//  CryptGuard_iOS
//

import SwiftUI

struct PasswordsDetail: View {
    var shouldCreate = false
    @Binding var passwordList: [String]?

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
    @State private var showDatabaseLockedAlert = false
    @Binding var databasePassword: String
    @Binding var databaseUnlocked: Bool
    
    init(id: UUID?, passwordList: Binding<[String]>, databasePassword: Binding<String>, databaseUnlocked: Binding<Bool>) {
        _passwordList = Binding(passwordList)
        _databasePassword = databasePassword
        _databaseUnlocked = databaseUnlocked
        
        if id == nil {
            shouldCreate = true
            pdCurrent = nil
        } else {
            if let currPD = passwordList.wrappedValue.map({ (encryptedPd) -> PasswordData in
                decryptPasswordData(encryptedPd)
            }).first(where: {
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
                
                .alert(isPresented: $showDatabaseLockedAlert, content: {
                    Alert(title: Text("Error"), message: Text("Database locked, please enter database password then try again."), dismissButton: .default(Text("OK")))
                })
                
                Section {
                    Button(action: {
                        if !databaseUnlocked {
                            showDatabaseLockedAlert.toggle()
                            return
                        }
                        createOrUpdatePasswordData()
                        saveChangesToUserDefaults(passwordList: passwordList)
                        alertCreatedShow.toggle()
                    }, label: {
                        Text("Save password data")
                    })
                    
                    .alert(isPresented: $alertCreatedShow, content: {
                            Alert(title: Text("Operation status"), message: Text("Password data successfully created."), dismissButton: .default(Text("OK")))})
                    
                    Button(action: {
                        if !databaseUnlocked {
                            showDatabaseLockedAlert.toggle()
                            return
                        }
                        removeCurrentPasswordData()
                        saveChangesToUserDefaults(passwordList: passwordList)
                        alertDeletedShow.toggle()
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
    
    fileprivate func createOrUpdatePasswordData() {
        let jsonEncoder = JSONEncoder()
        let encrypter = Encrypter()
        
        if (shouldCreate) {
            let pd = PasswordData(id: UUID(), siteName: siteName, username: username, email: email, password: password, additionalData: additionalData)
            let jsonData = try! jsonEncoder.encode(pd)
            let pdJsonString = String(data: jsonData, encoding: .utf8)!
            let pdEncrypted = encrypter.encryptStringAndGetBase64(inputString: pdJsonString, password: databasePassword)
            passwordList?.append(pdEncrypted)
        } else {
            let pdIndex = passwordList?.map({ (encryptedPd) -> PasswordData in
                decryptPasswordData(encryptedPd)
            }).firstIndex(where: {$0.id == pdCurrent?.id})
            
            let pd = PasswordData(id: pdCurrent!.id, siteName: siteName, username: username, email: email, password: password, additionalData: additionalData)
            let jsonData = try! jsonEncoder.encode(pd)
            let pdJsonString = String(data: jsonData, encoding: .utf8)!
            let pdEncrypted = encrypter.encryptStringAndGetBase64(inputString: pdJsonString, password: databasePassword)
            passwordList?[pdIndex!] = pdEncrypted
        }
    }
    
    fileprivate func decryptPasswordData(_ str: String) -> PasswordData {
        let encrypter = Encrypter()
        let encryptedJsonPDString = try! encrypter.decryptBase64String(inputString: str, password: $databasePassword.wrappedValue)
        let jsonEncoder = JSONDecoder()
        return try! jsonEncoder.decode(PasswordData.self, from: Data(encryptedJsonPDString.bytes))
    }
    
    fileprivate func removeCurrentPasswordData() {
        passwordList?.remove(at: (passwordList?.map({ (encryptedPd) -> PasswordData in
            decryptPasswordData(encryptedPd)
        }).firstIndex(where: {$0.id == pdCurrent?.id}))!)
    }
    
    fileprivate func copyToClipboard(sourceItem: String) {
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
    @State static private var pl: [String] = []
    @State static private var databaseUnlocked = true
    @State static private var databasePassword = ""
    
    static var previews: some View {
        PasswordsDetail(id: nil, passwordList: $pl, databasePassword: $databasePassword, databaseUnlocked: $databaseUnlocked)
    }
}
