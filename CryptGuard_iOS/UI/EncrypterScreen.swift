//
//  Encrypter.swift
//  CryptGuard_iOS
//


import SwiftUI

struct EncrypterScreen: View {
    
    @State private var password: String = ""
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
                    TextField("Passphrase", text: $password)
                        .multilineTextAlignment(.center)
                }
                
                .sheet(isPresented: $shouldPick, content: {
                    DocumentPicker(fileContent: $fileContent)
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
    
    func makeCoordinator() -> DocumentPickerCoordinator {
        return DocumentPickerCoordinator(fileContent: $fileContent)
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
    
    init(fileContent: Binding<[UInt8]>) {
        _fileContent = fileContent
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
                var buf: [UInt8] = [UInt8](repeating: 0, count: fileSize as Int)
                stream.open()
                let len = stream.read(&buf, maxLength: fileSize)
                for i in 0..<len {
                    print(String(format:"%02x ", buf[i]), terminator: "")
                }
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
