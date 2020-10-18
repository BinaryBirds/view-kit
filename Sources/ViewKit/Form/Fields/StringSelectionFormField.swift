//
//  StringSelectionFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 21..
//

/// can be used for option lists
public struct StringSelectionFormField: FormField {

    /// value of the selected option key
    public var value: String
    /// error message
    public var error: String?
    /// available options
    public var options: [FormFieldStringOption]
    
    public init(value: String = "", error: String? = nil, options: [FormFieldStringOption] = []) {
        self.value = value
        self.error = error
        self.options = options
    }

    /// validates if the given key is an available option
    public func validate(key: String) -> Bool {
        self.options.contains { $0.key == key }
    }
    
    public var leafData: LeafData {
        .dictionary([
            "value": .string(value),
            "error": .string(error),
            "options": .array(options.map(\.leafData))
        ])
    }
}
