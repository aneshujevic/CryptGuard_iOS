//
//  Database.swift
//  CryptGuard_iOS
//


import SwiftUI

struct DatabaseScreen: View {
    @State private var newDbPassword: String = ""
    @State private var showStrengthAlert: Bool = false
    @State private var showWrongPasswordAlert: Bool = false
    @State private var showSuccessfullPasswordChangeAlert: Bool = false
    @State private var databaseDocument: EncryptedDocument? = nil
    @State private var isExportingDatabase: Bool = false
    @Binding var databaseUnlocked: Bool
    @Binding var databasePassword: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 15, content: {
            Text("Database settings")
                    .font(.title)
            
            Image("key")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150, alignment: .center)
                .clipped()
                .shadow(radius: 3)
            
                .fileExporter(isPresented: $isExportingDatabase, document: databaseDocument, contentType: .data, defaultFilename: String("\(Date()).cryptguard.db"), onCompletion: {_ in})
            
                .alert(isPresented: $showStrengthAlert, content: {
                    Alert(title: Text("Alert"), message: Text("Password has to have 8 or more characters including uppercase letter, lowercase letter, number and punctuation mark."), dismissButton: .default(Text("OK")))
                })
            
                .alert(isPresented: $showSuccessfullPasswordChangeAlert, content: {
                    Alert(title: Text("Notification"), message: Text("Successfully changed database password."), dismissButton: .default(Text("OK")))
                })
            
                .alert(isPresented: $showWrongPasswordAlert, content: {
                    Alert(title: Text("Alert"), message: Text("Wrong password. Please try again."), dismissButton: .default(Text("OK")))
                })
            
            Form {
                Section {
                    TextField("Enter current database password", text: $databasePassword)
                    
                    Button(action: {
                        databasePassword = ""
                        databaseUnlocked = false
                    }, label: {
                        Text("Lock database")
                    }).disabled(!databaseUnlocked)
                    
                    Button(action: {
                        if validatePassphrase(databasePassword) {
                            if verifyDatabasePassphrase() {
                                databaseUnlocked = true
                            } else {
                                showWrongPasswordAlert.toggle()
                                return
                            }
                        } else {
                            showStrengthAlert.toggle()
                            return
                        }
                    }, label: {
                        Text("Unlock database")
                    }).disabled(databaseUnlocked)
                }
                
                

                Section {
                    TextField("Enter new database password", text: $newDbPassword)
                    Button(action: {
                        if verifyDatabasePassphrase() {
                            if !validatePassphrase(newDbPassword){
                                showStrengthAlert.toggle()
                                return
                            }
                            if reEncryptDatabase(databasePassword: databasePassword, newDbPassword: newDbPassword) {
                                showSuccessfullPasswordChangeAlert.toggle()
                            }
                        } else {
                            showWrongPasswordAlert.toggle()
                        }
                    }, label: {
                        Text("Change database password")
                    })
                }
                
                Section {
                    Text("Database operations")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        databaseDocument = createDatabaseDocument()
                        isExportingDatabase.toggle()
                    }, label: {
                        Text("Export database")
                    })
                
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Import database")
                    })

                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Delete current database")
                            .foregroundColor(.red)
                    })
                }
            }
        })
    }
    
    fileprivate func verifyDatabasePassphrase() -> Bool {
        if let data = UserDefaults.standard.value(forKey: "pdlist") as? Data {
            let encryptedPasswordDataList = try! PropertyListDecoder().decode(Array<String>.self, from: data)
            if encryptedPasswordDataList.count != 0 {
                do {
                    let encrypter = Encrypter()
                    try encrypter.decryptBase64String(inputString: encryptedPasswordDataList[0], password: databasePassword)
                    return true
                } catch {
                    showWrongPasswordAlert.toggle()
                    return false
                }
            } else {
                return true
            }
        }
        return true
    }
}

struct Database_Previews: PreviewProvider {
    @State private static var databasePassword: String = ""
    @State private static var databaseUnlocked: Bool = false
    static var previews: some View {
        DatabaseScreen(databaseUnlocked: $databaseUnlocked, databasePassword: $databasePassword)
    }
}
