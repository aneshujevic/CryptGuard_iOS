//
//  Database.swift
//  CryptGuard_iOS
//


import SwiftUI

struct DatabaseScreen: View {
    
    @State private var currentDBPassword: String = ""
    @State private var newDBPassword: String = ""
    
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
                    TextField("Enter current database password", text: $currentDBPassword)
                }

                Section {
                    Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                        Text("Lock database")
                    })
                    
                    Button(action: {}, label: {
                        Text("Unlock database")
                    })
                }
            
                Section {
                    TextField("Enter new database password", text: $currentDBPassword)
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
    static var previews: some View {
        DatabaseScreen()
    }
}
