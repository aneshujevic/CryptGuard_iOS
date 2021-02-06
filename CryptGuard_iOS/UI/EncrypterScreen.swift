//
//  Encrypter.swift
//  CryptGuard_iOS
//


import SwiftUI

struct EncrypterScreen: View {
    
    @State private var passphrase: String = ""
    @State private var shouldPick: Bool = false
    @State private var fileContent: [UInt8] = []
    @State private var shouldShowAlert: Bool = false
    @State private var isExporting: Bool = false
    @State private var encryptedDocumentData: Data? = nil
    @State private var isDecrypting: Bool = false
    @State private var fileName: String = ""
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""
    
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 15, content: {
            Text("Encrypter")
                    .font(.title)
            
            Image("lock_circle")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150, alignment: .center)
                .clipped()
                .shadow(radius: 3)
            
            Text("Choose the file to be encrypted and enter the passphrase")
                .font(.callout)
                .multilineTextAlignment(.center)
            
                .alert(isPresented: $shouldShowAlert, content: {
                    Alert(title: Text(alertTitle != "" ? alertTitle: "Alert"), message: Text(alertMessage != "" ? alertMessage : "Password has to have 8 or more characters including uppercase letter, lowercase letter, number and punctuation mark."), dismissButton: .default(Text("OK")))
            })
            
                .fileExporter(isPresented: $isExporting, document: EncryptedDocument(data: encryptedDocumentData ?? nil), contentType: .data, defaultFilename: fileName) { _ in }
            
            Form {
                Section {
                    TextField("Passphrase", text: $passphrase)
                        .multilineTextAlignment(.center)
                }
                
                .sheet(isPresented: $shouldPick, content: {
                    DocumentPicker(fileContent: $fileContent, passphrase: $passphrase, shouldShowAlert: $shouldShowAlert, encryptedDocumentData:   $encryptedDocumentData, isExporting: $isExporting, isDecrypting: $isDecrypting, fileName: $fileName, alertMessage: $alertMessage, alertTitle: $alertTitle)
                })

                
                Section {
                    Button(action: {
                        shouldPick.toggle()
                        isDecrypting = false
                    }, label: {
                        Text("Encrypt a file")
                    })
                    
                    Button(action: {
                        shouldPick.toggle()
                        isDecrypting = true
                    }, label: {
                        Text("Decrypt a file")
                    })
                }
            }
        })
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var fileContent: [UInt8]
    @Binding var passphrase: String
    @Binding var shouldShowAlert: Bool
    @Binding var encryptedDocumentData: Data?
    @Binding var isExporting: Bool
    @Binding var isDecrypting: Bool
    @Binding var fileName: String
    @Binding var alertMessage: String
    @Binding var alertTitle: String
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(fileContent: $fileContent, passphrase: $passphrase, shouldShowAlert: $shouldShowAlert, encryptedDocumentData: $encryptedDocumentData, isExporting: $isExporting, isDecrypting: $isDecrypting, fileName: $fileName, alertMessage: $alertMessage, alertTitle: $alertTitle)
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
    @Binding var fileContent: [UInt8]
    @Binding var passphrase: String
    @Binding var shouldShowAlert: Bool
    @Binding var encryptedDocumentData: Data?
    @Binding var isExporting: Bool
    @Binding var isDecrypting: Bool
    @Binding var fileName: String
    @Binding var alertMessage: String
    @Binding var alertTitle: String
    
    init(fileContent: Binding<[UInt8]>, passphrase: Binding<String>, shouldShowAlert: Binding<Bool>,
         encryptedDocumentData: Binding<Data?>, isExporting: Binding<Bool>, isDecrypting: Binding<Bool>, fileName: Binding<String>, alertMessage: Binding<String>, alertTitle: Binding<String>) {
        _fileContent = fileContent
        _passphrase = passphrase
        _shouldShowAlert = shouldShowAlert
        _encryptedDocumentData = encryptedDocumentData
        _isExporting = isExporting
        _isDecrypting = isDecrypting
        _fileName = fileName
        _alertTitle = alertTitle
        _alertMessage = alertMessage
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if !validatePassphrase(passphrase) {
            shouldShowAlert = true
            return
        }
        
        let fileURL = urls[0]
        
        fileName = "\(fileURL.deletingPathExtension().lastPathComponent).cgfe"
        
        if let stream: InputStream = InputStream(url: fileURL) {
            
            defer {
                stream.close()
            }
            
            let encrypter = Encrypter()
            
            if isDecrypting {
                do {
                let decryptedContent = try encrypter.decryptStream(inputStream: stream, password: passphrase)
                encryptedDocumentData = Data(decryptedContent.bytes)
                } catch {
                    encryptedDocumentData = nil
                    alertMessage = "Incorrect passphrase, please try again."
                    alertTitle = "Error"
                    shouldShowAlert.toggle()
                }
            } else {
                let encryptedContent = encrypter.encryptStreamAndGetBase64(inputStream: stream, password: passphrase)
                encryptedDocumentData = Data(encryptedContent.utf8)
            }
            
            isExporting.toggle()
        }
    }
}

struct Encrypter_Previews: PreviewProvider {
    static var previews: some View {
        EncrypterScreen()
    }
}
