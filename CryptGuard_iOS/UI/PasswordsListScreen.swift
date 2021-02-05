//
//  PasswordsList.swift
//  CryptGuard_iOS
//


import SwiftUI

struct PasswordsListScreen: View {
    @State private var passwordList: [PasswordData] = []
    @State private var showPasswordAlert: Bool = false
    @State private var navigateDatabaseScreen: Bool = false
    @Binding private var databasePassword: String
    @Binding private var databaseUnlocked: Bool
    
    init(databasePassword: Binding<String>, databaseUnlocked: Binding<Bool>) {
        if databasePassword.wrappedValue == "" {
            _showPasswordAlert = State(initialValue: true)
        }
        _databasePassword = databasePassword
        _databaseUnlocked = databaseUnlocked
        
        UserDefaults.standard.synchronize()
        if let data = UserDefaults.standard.value(forKey: "pdlist") as? Data {
            let pdl = try! PropertyListDecoder().decode(Array<PasswordData>.self, from: data)
            _passwordList = State(initialValue: pdl)
        }
    }
    
    var body: some View{
        VStack {
            Text("List of password data")
                .font(.title)
            Form {
                Section {
                    if passwordList.count == 0 {
                        Text("No password data yet.")
                    } else {
                        List(passwordList) { passwordData in
                            PasswordsListRow(passwordList: $passwordList, passwordData: passwordData)
                        }
                    }
                }
                
                .alert(isPresented: $showPasswordAlert, content: {
                    Alert(
                        title: Text("Alert"),
                        message: Text("Enter the database password to access password data."),
                        dismissButton: .default(Text("OK"))
                    )}
                )
                
                Section{
                    if databaseUnlocked {
                        NavigationLink("Add password data", destination: PasswordsDetail(id: nil, passwordList: $passwordList))
                            .font(.callout)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationBarTitle("Passwords list")
    }
}

struct PasswordsList_Previews: PreviewProvider {
    @State private static var databasePassword: String = ""
    @State private static var databaseUnlocked: Bool = false
    static var previews: some View {
        PasswordsListScreen(databasePassword: $databasePassword, databaseUnlocked: $databaseUnlocked)
    }
}

struct PasswordsListRow: View {
    @Binding var passwordList: [PasswordData]
    let passwordData: PasswordData
    
    var body: some View {
        NavigationLink(destination: PasswordsDetail(id: passwordData.id, passwordList: $passwordList)) {
                HStack(){
                    VStack(alignment: .leading, spacing: nil, content: {
                        Text(passwordData.siteName ?? "")
                            .font(.system(size: 20, weight: .medium, design: .default))
                            .underline()
                        Spacer()
                        Text(passwordData.username ?? "")
                            .font(.system(size: 17, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                    })
                    Spacer()
                    Image("eye")
            }
        }
    }
}
