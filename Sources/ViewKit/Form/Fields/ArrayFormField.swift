//
//  ArrayFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 23..
//

/// can be used to store multiple text values
public struct ArrayFormField: FormField {
    
    ///values to store
    public var values: [String]
    ///error message
    public var error: String?

    public init(values: [String] = [], error: String? = nil) {
        self.values = values
        self.error = error
    }
}
