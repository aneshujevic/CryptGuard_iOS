//
//  ContentView.swift
//  CryptGuard_iOS
//

import SwiftUI

struct ContentView: View {
var body: some View {
    NavigationView {
        List() {
            NavigationLink(
                destination: PasswordsListScreen()) {
                OptionsRow(option: menuOptions[0])
            }
            NavigationLink(
                destination: DatabaseScreen()) {
                OptionsRow(option: menuOptions[1])
            }
            NavigationLink(
                destination: EncrypterScreen()) {
                OptionsRow(option: menuOptions[2])
            }
            NavigationLink(
                destination: PasswordGeneratorScreen()) {
                OptionsRow(option: menuOptions[3])
            }
            NavigationLink(
                destination: OnlineAccountScreen()) {
                OptionsRow(option: menuOptions[4])
            }
        }
        .foregroundColor(Color(UIColor(named: "charleston_green") ?? .black))
        .navigationBarTitle("CryptGuard")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct OptionsRow: View {
    let option: Option
    
    var body: some View {
        HStack(spacing: 15, content: {
            Image(option.iconName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .cornerRadius(50)
            VStack(alignment: .leading, spacing: 3, content: {
                Text(option.title)
                    .font(.system(size: 21, weight: .medium, design: .default))
                Text(option.description)
            })
        })
    }
}
