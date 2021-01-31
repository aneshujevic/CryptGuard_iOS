//
//  PasswordGenerator.swift
//  CryptGuard_iOS
//


import SwiftUI

struct PasswordGeneratorScreen: View {
    
    @State private var length = "32"
    @State private var generatedPassword = ""
    @State private var lengthError = false
    @State private var textCopiedAlert = false
    
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 15, content: {
            Text("Password generator")
                    .font(.title)
            
            Image("dice")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150, alignment: .center)
                .clipped()
                .shadow(radius: 3)
            
            Form {
                Section {
                    TextField("Length of password", text: $length)
                        .multilineTextAlignment(.center)
                        .keyboardType(/*@START_MENU_TOKEN@*/.numberPad/*@END_MENU_TOKEN@*/)
                        .border(lengthError == true ? Color.red : Color.white, width: 1)
                    
                    Text("Enter the desired length of the password")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                Section {
                    TextField("Generated password will show here", text: $generatedPassword)
                        .multilineTextAlignment(.center)
                        .padding(0)
                        .onLongPressGesture {
                            UIPasteboard.general.string = generatedPassword
                            textCopiedAlert = true
                        }
                        .alert(isPresented: $textCopiedAlert, content: {
                            Alert(title: Text("Operation status"), message: Text("Password successfully copied to clipboard"), dismissButton: .default(Text("OK")))
                        })
                }
                
                Section {
                    Button(action: {
                        if length.count == 0 || Int(length)! <= 0 || Int(length)! > 512 {
                            lengthError = true
                            
                                
                            return
                        }
                        let pd = PasswordGenerator()
                        generatedPassword = pd.generate(Int(length) ?? 32)
                    }, label: {
                        Text("Generate a password")
                    })
                    .alert(isPresented: $lengthError, content: {
                            Alert(
                                title: Text("Validation error"),
                                message: Text("Password length should be between 0 and 512"), dismissButton: .default(Text("ok")))
                    })
                }
            }
        })
    }
}

struct PasswordGenerator_Previews: PreviewProvider {
    static var previews: some View {
        PasswordGeneratorScreen()
    }
}
