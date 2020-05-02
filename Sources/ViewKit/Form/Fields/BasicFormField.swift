//
//  BasicFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 21..
//

/// used to store simple text values
public struct BasicFormField: FormField {

    /// value of the form field
    public var value: String
    /// error message
    public var error: String?
    
    public init(value: String = "", error: String? = nil) {
        self.value = value
        self.error = error
    }
}
