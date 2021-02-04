//
//  Encrypter.swift
//  CryptGuard_iOS
//


import SwiftUI

struct EncrypterScreen: View {
    
    @State private var passphrase: String = ""
    @State private var shouldPick: Bool = false
    @State private var fileContent: [UInt8] = []
    
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
            
            Form {
                Section {
                    TextField("Passphrase", text: $passphrase)
                        .multilineTextAlignment(.center)
                }
                
                .sheet(isPresented: $shouldPick, content: {
                    DocumentPicker(fileContent: $fileContent, passphrase: $passphrase)
                })

                
                Section {
                    Button(action: {
                        shouldPick.toggle()
                    }, label: {
                        Text("Encrypt a file")
                    })
                    
                    Button(action: {}, label: {
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
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(fileContent: $fileContent, passphrase: $passphrase)
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
    
    init(fileContent: Binding<[UInt8]>, passphrase: Binding<String>) {
        _fileContent = fileContent
        _passphrase = passphrase
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        do {
            let fileURL = urls[0]
            let attr = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            let fileSize = attr[FileAttributeKey.size] as! Int
            /*
            fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            print("HEEEE")
            print(fileContent)
            */
            if let stream: InputStream = InputStream(url: fileURL) {
                
                let encrypter = Encrypter()
                
                print("Encrypted:")
                let x = encrypter.encryptStreamAndGetBase64(inputStream: stream, password: "hello")
                print(x)
                
                print("Decrypted")
                print(encrypter.decryptBase64String(inputString: x, password: "hello"))
                
                stream.close()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct Encrypter_Previews: PreviewProvider {
    static var previews: some View {
        EncrypterScreen()
    }
}
