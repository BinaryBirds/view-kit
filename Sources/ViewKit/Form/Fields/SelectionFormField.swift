//
//  SelectionFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 21..
//

import Foundation

/// can be used for option lists
public struct SelectionFormField: FormField {

    /// value of the selected option key
    public var value: String
    /// error message
    public var error: String?
    /// available options
    public var options: [FormFieldOption]
    
    public init(value: String = "", error: String? = nil, options: [FormFieldOption] = []) {
        self.value = value
        self.error = error
        self.options = options
    }
}

