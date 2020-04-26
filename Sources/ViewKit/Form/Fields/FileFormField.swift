//
//  FileFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 21..
//

import Foundation

/// can be used for simple file uploads
public struct FileFormField: FormField {

    /// generic value field
    public var value: String
    /// error message
    public var error: String?
    /// file data
    public var data: Data?
    /// should delete the file
    public var delete: Bool
    
    public init(value: String = "",
                error: String? = nil,
                data: Data? = nil,
                delete: Bool = false) {
        self.value = value
        self.error = error
        self.data = data
        self.delete = delete
    }
}
