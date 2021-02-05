//
//  PasswordsList.swift
//  CryptGuard_iOS
//


import SwiftUI

struct PasswordsListScreen: View {
    @State private var passwordList: [String] = []
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
            let encryptedPasswordDataList = try! PropertyListDecoder().decode(Array<String>.self, from: data)
            _passwordList = State(initialValue: encryptedPasswordDataList)
        }
    }
    
    var body: some View{
        VStack {
            Form {
                Section {
                    if databaseUnlocked {
                        if passwordList.count == 0 {
                            Text("No password data yet.")
                        } else {
                            List(passwordList.map( {decryptPasswordData($0)} )) { passwordData in
                                PasswordsListRow(passwordList: $passwordList, databaseUnlocked: $databaseUnlocked, databasePassword: $databasePassword, passwordData: passwordData)
                            }
                        }
                    } else {
                        Text("Enter database password to access the data.")
                            .foregroundColor(.gray)
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
                        NavigationLink("Add password data", destination: PasswordsDetail(id: nil, passwordList: $passwordList, databasePassword: $databasePassword, databaseUnlocked: $databaseUnlocked))
                            .font(.callout)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .navigationBarTitle("Passwords list")
    }
    
    fileprivate func decryptPasswordData(_ str: String) -> PasswordData {
        let encrypter = Encrypter()
        let decryptedJSONPd = try! encrypter.decryptBase64String(inputString: str, password: $databasePassword.wrappedValue)
        let jsonEncoder = JSONDecoder()
        return try! jsonEncoder.decode(PasswordData.self, from: Data(decryptedJSONPd.utf8))
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
    @Binding var passwordList: [String]
    @Binding var databaseUnlocked: Bool
    @Binding var databasePassword: String
    let passwordData: PasswordData
    
    var body: some View {
        NavigationLink(destination: PasswordsDetail(id: passwordData.id, passwordList: $passwordList, databasePassword: $databasePassword, databaseUnlocked: $databaseUnlocked)) {
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
