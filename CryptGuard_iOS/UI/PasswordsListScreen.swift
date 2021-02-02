//
//  PasswordsList.swift
//  CryptGuard_iOS
//


import SwiftUI

struct PasswordsListScreen: View {
    @State private var passwordList: [PasswordData] = []
    
    init() {
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
                Section{
                    NavigationLink(
                        destination: PasswordsDetail(id: nil, passwordList: $passwordList)) {
                        Text("Add password data")
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
    static var previews: some View {
        PasswordsListScreen()
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
