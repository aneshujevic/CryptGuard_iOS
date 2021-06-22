//
//  OnlineAccount.swift
//  CryptGuard_iOS
//
//  Created by bababoey on 24/01/2021.
//

import SwiftUI

struct OnlineAccountScreen: View {
    var server_address = "http://192.168.1.9:8080"
    @State private var token: String = ""
    @State private var showAlert: Bool = false
    @State private var alertText: String = ""
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
                                alertText = "Check your username if you are already registered."
                                showAlert = true
                                return
                            }
                            
                            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                alertText = dataString
                                showAlert = true
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
                                alertText = "Bad credentials"
                                showAlert = true
                                return
                            }
                            
                            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                alertText = "Successfully logged in."
                                showAlert = true
                                token = String(dataString.split(separator:":")[1])
                            }
                        }
                        task.resume()
                    }, label: {
                        Text("Log in")
                    })
                }
                
                Section {
                    Button(action: {
                        let url = URL(string: server_address + "/api/database")
                        guard let requestURL = url else {fatalError()}
                                                
                        var request = URLRequest(url: requestURL)
                        request.httpMethod = "GET"
                        request.setValue("Bearer " + token.dropFirst().dropLast(2), forHTTPHeaderField: "Authorization")
                                                    
                        let task = URLSession.shared.dataTask(with: request) {
                            (data, response, error) in
                            if let error = error {
                                alertText = "Couldn't get database from cloud."
                                showAlert = true
                                return
                            }
                            
                            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                alertText = "Database successfully loaded."
                                showAlert = true
                                
                                deleteDatabaseUserDefaults()
                                // Importing database
                                do {
                                var encryptedPasswordDataList: [String] = []
                                let encryptedDocumentData = data
                                let databaseString = String(data: encryptedDocumentData , encoding: .utf8)!
                                for row in databaseString.split(separator: "\n") {
                                    _ = row.split(separator: ",")[0]
                                    let pd = row.split(separator: ",")[1].replacingOccurrences(of: ".", with: "\n")
                                    encryptedPasswordDataList.append(pd)
                                    saveChangesToUserDefaults(passwordList: encryptedPasswordDataList)
                                }
                                } catch {
                                    
                                }
                            }
                        }
                        task.resume()
                    }, label: {
                        Text("Get online database")
                    })
                    
                    Button(action: {
                        let url = URL(string: server_address + "/api/database")
                        guard let requestURL = url else {fatalError()}
                        let boundary = "Boundary-\(UUID().uuidString)"
                        
                        var request = URLRequest(url: requestURL)
                        request.httpMethod = "POST"
                        request.setValue("Bearer " + token.dropFirst().dropLast(2), forHTTPHeaderField: "Authorization")
                        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                        
                        let postString = convertFileData(fieldName: "file", filename: UUID().uuidString, mimeType: "application/octet-stream", fileData: (createDatabaseDocument()?.data)!, boundary: boundary)
                            
                        let httpBody = NSMutableData()
                        httpBody.append(postString)
                        httpBody.appendString("--\(boundary)--")
                        
                        request.httpBody = httpBody as Data
                        
                        let task = URLSession.shared.dataTask(with: request) {
                            (data, response, error) in
                            if let error = error {
                                alertText = "Couldn't upload database to the cloud."
                                showAlert = true
                                return
                            }
                            
                            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                alertText = "Database successfully uploaded."
                                showAlert = true
                            }
                        }
                        task.resume()
                    }, label: {
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
                                alertText = "Error in registration. Is you username unique?"
                                showAlert = true
                                return
                            }
                            
                            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                                alertText = "Successfully registered."
                                showAlert = true
                            }
                        }
                        task.resume()
                    }, label: {
                        Text("Register")
                    })
                }
                .alert(isPresented: $showAlert, content: {
                    Alert(
                        title: Text("Alert"),
                        message: Text(alertText),
                        dismissButton: .default(Text("OK"))
                    )}
                )
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
    
    func convertFileData(fieldName: String, filename: String, mimeType: String, fileData: Data, boundary: String) -> Data {
        let data = NSMutableData()
        
        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")
        
        return data as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}

struct OnlineAccount_Previews: PreviewProvider {
    static var previews: some View {
        OnlineAccountScreen()
    }
}
