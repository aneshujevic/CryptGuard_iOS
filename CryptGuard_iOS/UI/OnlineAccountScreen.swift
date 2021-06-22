//
//  OnlineAccount.swift
//  CryptGuard_iOS
//
//  Created by bababoey on 24/01/2021.
//

import SwiftUI

struct OnlineAccountScreen: View {
    var server_address = "http://192.168.1.9:8080"
    @State private var username: String = ""
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
                    TextField("Username", text: $username)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        let url = URL(string: server_address + "/api/request-login")
                        guard let requestURL = url else {fatalError()}
                        let boundary = "Boundary-\(UUID().uuidString)"
                        
                        var request = URLRequest(url: requestURL)
                        request.httpMethod = "POST"
                        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                        
                        let postString = convertFormField(named: "username", value: username, using: boundary)
                            + "--\(boundary)--"
                        
                        request.httpBody = postString.data(using: String.Encoding.utf8)
                        
                        let task = URLSession.shared.dataTask(with: request) {
                            (data, response, error) in
                            if let error = error {
                                print("error in request \(error)")
                                return
                            }
                            
                            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                print("response data: \(dataString)")
                            }
                        }
                        task.resume()
                    }, label: {
                        Text("Request login password")
                    })
                }
                
                Section {
                    TextField("Password", text: $password)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        let url = URL(string: server_address + "/api/login")
                        guard let requestURL = url else {fatalError()}
                        let boundary = "Boundary-\(UUID().uuidString)"
                        
                        var request = URLRequest(url: requestURL)
                        request.httpMethod = "POST"
                        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                        
                        let postString = convertFormField(named: "username", value: username, using: boundary)
                            + convertFormField(named: "password", value: password, using: boundary)
                            + "--\(boundary)--"
                        
                        request.httpBody = postString.data(using: String.Encoding.utf8)
                        
                        let task = URLSession.shared.dataTask(with: request) {
                            (data, response, error) in
                            if let error = error {
                                print("error in request \(error)")
                                return
                            }
                            
                            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                print("response data: \(dataString)")
                            }
                        }
                        task.resume()
                    }, label: {
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
                    
                    Button(action: {
                        let url = URL(string: server_address + "/api/register")
                        guard let requestURL = url else {fatalError()}
                        let boundary = "Boundary-\(UUID().uuidString)"
                        
                        var request = URLRequest(url: requestURL)
                        request.httpMethod = "POST"
                        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                        
                        let postString = convertFormField(named: "email", value: emailRegistration, using: boundary)
                            + convertFormField(named: "username", value: usernameRegistration, using: boundary)
                            + "--\(boundary)--"
                        
                        request.httpBody = postString.data(using: String.Encoding.utf8)
                        
                        let task = URLSession.shared.dataTask(with: request) {
                            (data, response, error) in
                            if let error = error {
                                print("error in request \(error)")
                                return
                            }
                            
                            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                print("response data: \(dataString)")
                            }
                        }
                        task.resume()
                    }, label: {
                        Text("Register")
                    })
                }
            }
        })
    }
    
    func convertFormField(named name: String, value: String, using boundary: String) -> String {
        var fieldString = "--\(boundary)\r\n"
        fieldString += "Content-Disposition: form-data; name=\"\(name)\"\r\n"
        fieldString += "\r\n"
        fieldString += "\(value)\r\n"
        
        return fieldString
    }
}

struct OnlineAccount_Previews: PreviewProvider {
    static var previews: some View {
        OnlineAccountScreen()
    }
}
