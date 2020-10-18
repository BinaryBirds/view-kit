//
//  StringFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 21..
//

/// used to store simple string values
public struct StringFormField: FormField {

    /// value of the form field
    public var value: String
    /// error message
    public var error: String?
    
    public init(value: String = "", error: String? = nil) {
        self.value = value
        self.error = error
    }

    public var leafData: LeafData {
        .dictionary([
            "value": .string(value),
            "error": .string(error),
        ])
    }
    
}
