//
//  OnlineAccount.swift
//  CryptGuard_iOS
//
//  Created by bababoey on 24/01/2021.
//

import SwiftUI

struct OnlineAccountScreen: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailRegistration: String = ""
    @State private var usernameRegistration: String = ""
    
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 15, content: {
            Text("Online account")
                    .font(.title)
            
            Image("cloud_circle")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150, alignment: .center)
                .clipped()
                .shadow(radius: 3)
            
            Form {
                Section {
                    TextField("Username", text: $email)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {}, label: {
                        Text("Request login password")
                    })
                }
                
                Section {
                    TextField("Password", text: $password)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {}, label: {
                        Text("Log in")
                    })
                }
                
                Section {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Get online database")
                    })
                    
                    Button(action: {}, label: {
                        Text("Save database online")
                    })
                }
                
                Section {
                    Text("Registration")
                        .multilineTextAlignment(.center)
                        .font(.title2)
                    
                    TextField("Email", text: $emailRegistration)
                        .multilineTextAlignment(.center)

                    TextField("Username", text: $usernameRegistration)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {}, label: {
                        Text("Register")
                    })
                }
            }
        })
    }
}

struct OnlineAccount_Previews: PreviewProvider {
    static var previews: some View {
        OnlineAccountScreen()
    }
}
