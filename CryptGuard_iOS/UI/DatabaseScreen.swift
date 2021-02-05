//
//  Database.swift
//  CryptGuard_iOS
//


import SwiftUI

struct DatabaseScreen: View {
    @State private var newDBPassword: String = ""
    @State private var showStrengthAlert: Bool = false
    @State private var showWrongPasswordAlert: Bool = false
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
            
            Form {
                Section {
                    TextField("Enter current database password", text: $databasePassword)
                }

                Section {
                    Button(action: {
                        databasePassword = ""
                        databaseUnlocked = false
                    }, label: {
                        Text("Lock database")
                    }).disabled(!databaseUnlocked)
                    
                    .alert(isPresented: $showStrengthAlert, content: {
                        Alert(title: Text("Alert"), message: Text("Password has to have 8 or more characters including uppercase letter, lowercase letter, number and punctuation mark."), dismissButton: .default(Text("OK")))
                    })
                    
                    .alert(isPresented: $showWrongPasswordAlert, content: {
                        Alert(title: Text("Alert"), message: Text("Wrong password. Please try again."), dismissButton: .default(Text("OK")))
                    })
                    
                    Button(action: {
                        if validatePassphrase(databasePassword) {
                            if let data = UserDefaults.standard.value(forKey: "pdlist") as? Data {
                                let encryptedPasswordDataList = try! PropertyListDecoder().decode(Array<String>.self, from: data)
                                if encryptedPasswordDataList.count != 0 {
                                    do {
                                        let encrypter = Encrypter()
                                        try encrypter.decryptBase64String(inputString: encryptedPasswordDataList[0], password: databasePassword)
                                    } catch {
                                        showWrongPasswordAlert.toggle()
                                    }
                                }
                            }
                            databaseUnlocked = true
                        } else {
                            showStrengthAlert = true
                        }
                    }, label: {
                        Text("Unlock database")
                    }).disabled(databaseUnlocked)
                }
            
                Section {
                    TextField("Enter new database password", text: $newDBPassword)
                }

                Section {
                    Button(action: {}, label: {
                        Text("Change database password")
                    })
                }
                
                Section {
                    Text("Database operations")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
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
}

struct Database_Previews: PreviewProvider {
    @State private static var databasePassword: String = ""
    @State private static var databaseUnlocked: Bool = false
    static var previews: some View {
        DatabaseScreen(databaseUnlocked: $databaseUnlocked, databasePassword: $databasePassword)
    }
}
