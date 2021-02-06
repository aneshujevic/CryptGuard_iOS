//
//  Database.swift
//  CryptGuard_iOS
//


import SwiftUI

struct DatabaseScreen: View {
    @State private var newDbPassword: String = ""
    @State private var showStrengthAlert: Bool = false
    @State private var showWrongPasswordAlert: Bool = false
    @State private var showSuccessfulAlert: Bool = false
    @State private var databaseDocument: EncryptedDocument? = nil
    @State private var isExportingDatabase: Bool = false
    @State private var isImportingDatabase: Bool = false
    @State private var showErrorAlert: Bool = false
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
                    
                    .alert(isPresented: $showStrengthAlert, content: {
                        Alert(title: Text("Alert"), message: Text("Password has to have 8 or more characters including uppercase letter, lowercase letter, number and punctuation mark."), dismissButton: .default(Text("OK")))
                    })
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
                                showSuccessfulAlert.toggle()
                            }
                        } else {
                            showWrongPasswordAlert.toggle()
                        }
                    }, label: {
                        Text("Change database password")
                    })
                    .alert(isPresented: $showWrongPasswordAlert, content: {
                        Alert(title: Text("Alert"), message: Text("Wrong password. Please try again."), dismissButton: .default(Text("OK")))
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
                
                    Button(action: {
                        isImportingDatabase.toggle()
                    }, label: {
                        Text("Import database")
                    })

                    Button(action: {
                        deleteDatabaseUserDefaults()
                        showSuccessfulAlert.toggle()
                    }, label: {
                        Text("Delete current database")
                            .foregroundColor(.red)
                    })
                    
                    .sheet(isPresented: $isImportingDatabase, content: {
                        DocumentPicker(showErrorAlert: $showErrorAlert)
                    })
                    
                    .alert(isPresented: $showSuccessfulAlert, content: {
                        Alert(title: Text("Notification"), message: Text("Successfully done."), dismissButton: .default(Text("OK")))
                    })
                }
            }
        })
    }
    
    func verifyDatabasePassphrase() -> Bool {
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
    
    struct DocumentPicker: UIViewControllerRepresentable {
        @Binding var showErrorAlert: Bool
        
        func makeCoordinator() -> DocumentPickerCoordinator {
            return DocumentPickerCoordinator(showErrorAlert: $showErrorAlert)
        }

        func makeUIViewController(context: Context) -> some UIViewController {
            let controller: UIDocumentPickerViewController
            
            controller = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
            
            controller.delegate = context.coordinator
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }

    class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        @Binding var showErrorAlert: Bool
        
        init(showErrorAlert: Binding<Bool>) {
            _showErrorAlert = showErrorAlert
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let fileURL = urls[0]
                        
            if let stream: InputStream = InputStream(url: fileURL) {
                
                defer {
                    stream.close()
                }
                
                deleteDatabaseUserDefaults()
                // Importing database
                var encryptedPasswordDataList: [String] = []
                do {
                    let encryptedDocumentData = try Data(reading: stream)
                    let databaseString = String(data: encryptedDocumentData , encoding: .utf8)!
                    for row in databaseString.split(separator: "\n") {
                        _ = row.split(separator: ",")[0]
                        let pd = row.split(separator: ",")[1].replacingOccurrences(of: ".", with: "\n")
                        encryptedPasswordDataList.append(pd)
                        saveChangesToUserDefaults(passwordList: encryptedPasswordDataList)
                    }
                } catch  {
                    showErrorAlert.toggle()
                }
            }
        }
    }
}

struct Database_Previews: PreviewProvider {
    @State private static var databasePassword: String = ""
    @State private static var databaseUnlocked: Bool = false
    static var previews: some View {
        DatabaseScreen(databaseUnlocked: $databaseUnlocked, databasePassword: $databasePassword)
    }
}
