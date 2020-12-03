//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 12. 01..
//

import Foundation

/// can be used for multiple file uploads
public struct FileArrayFormField: FormField {

    /// file data values
    public var values: [FileDataValue]

    /// error message
    public var error: String?
    
    /// public init
    public init(values: [FileDataValue] = [], error: String? = nil) {
        self.values = values
        self.error = error
    }

    public var leafData: LeafData {
        .dictionary([
            "values": .array(values.map(\.leafData)),
            "error": .string(error),
        ])
    }
}
