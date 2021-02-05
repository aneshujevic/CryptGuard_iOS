//
//  EncryptedDocument.swift
//  CryptGuard_iOS
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct EncryptedDocument: FileDocument {
    static var readableContentTypes: [UTType] {[.data]}
    
    var data: Data?
    
    init(data: Data?) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = data
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data ?? Data())
    }
    
    
}
