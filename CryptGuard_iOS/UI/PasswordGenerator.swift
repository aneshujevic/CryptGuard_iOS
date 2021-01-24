//
//  PasswordGenerator.swift
//  CryptGuard_iOS
//


import SwiftUI

struct PasswordGenerator: View {
    
    @State private var length: String = "32"
    @State private var generatedPassword: String = "Generated password will show here"
    
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
                    TextField("", text: $length)
                        .multilineTextAlignment(.center)
                    Text("Enter the desired length of the password")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                Section {
                    TextField("", text: $generatedPassword)
                }
                
                Section {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Generate a password")
                    })
                }
            }
        })
    }
}

struct PasswordGenerator_Previews: PreviewProvider {
    static var previews: some View {
        PasswordGenerator()
    }
}
