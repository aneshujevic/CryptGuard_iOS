//
//  Encrypter.swift
//  CryptGuard_iOS
//
//  Created by bababoey on 24/01/2021.
//

import SwiftUI

struct Encrypter: View {
    
    @State private var password: String = ""
    
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
                }

                Section {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
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

struct Encrypter_Previews: PreviewProvider {
    static var previews: some View {
        Encrypter()
    }
}
