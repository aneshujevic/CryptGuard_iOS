//
//  PasswordsList.swift
//  CryptGuard_iOS
//


import SwiftUI

struct PasswordsListScreen: View {
    
    init() {
        if let data = UserDefaults.standard.value(forKey: "pdlist") as? Data {
            let pdl = try? PropertyListDecoder().decode(Array<PasswordData>.self, from: data)
            passwordDataList = pdl!
        } 
    }
    
    var body: some View{
        VStack {
            Text("List of password data")
                .font(.title)
            Form {
                Section {
                    if passwordDataList.count == 0 {
                        Text("No password data yet.")
                    } else {
                        List(passwordDataList) { passwordData in
                            PasswordsListRow(passwordData: passwordData)
                        }
                    }
                }
                Section{
                    NavigationLink(
                        destination: PasswordsDetail(id: nil)) {
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
    
    let passwordData: PasswordData
    
    var body: some View {
        NavigationLink(destination: PasswordsDetail(id: passwordData.id)) {
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
