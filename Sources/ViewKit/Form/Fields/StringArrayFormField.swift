//
//  StringArrayFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 23..
//

/// can be used to store multiple string values
public struct StringArrayFormField: FormField {
    
    ///values to store
    public var values: [String]
    ///error message
    public var error: String?

    public init(values: [String] = [], error: String? = nil) {
        self.values = values
        self.error = error
    }
    
    public var leafData: LeafData {
        .dictionary([
            "values": .array(values.map { .string($0) }),
            "error": .string(error),
        ])
    }
}
