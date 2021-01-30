//
//  PasswordsList.swift
//  CryptGuard_iOS
//


import SwiftUI

struct PasswordsListScreen: View {
    var body: some View{
        VStack {
            Text("List of password data")
                .font(.title)
            List(passwordDataList) { passwordData in
                PasswordsListRow(passwordData: passwordData)
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
                    Text(passwordData.siteName)
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .underline()
                    Spacer()
                    Text(passwordData.username)
                        .font(.system(size: 17, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray)
                })
                Spacer()
                Image("eye")
            }
        }
    }
}
