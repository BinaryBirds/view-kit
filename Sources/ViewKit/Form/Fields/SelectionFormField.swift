//
//  SelectionFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 21..
//

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

    /// validates if the given key is an available option
    public func validate(key: String) -> Bool {
        self.options.contains { $0.key == key }
    }
}
