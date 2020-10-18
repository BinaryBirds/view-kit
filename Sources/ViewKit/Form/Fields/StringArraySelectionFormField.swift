//
//  StringArraySelectionFormField.swift
//  FeatherCMS
//
//  Created by Tibor Bodecs on 2020. 07. 22..
//

import Foundation

/// can be used for option lists
public struct StringArraySelectionFormField: FormField {

    /// values of the selected option keys
    public var values: [String]
    /// error message
    public var error: String?
    /// available options
    public var options: [FormFieldStringOption]

    public init(values: [String] = [], error: String? = nil, options: [FormFieldStringOption] = []) {
        self.values = values
        self.error = error
        self.options = options
    }
    
    public var leafData: LeafData {
        .dictionary([
            "values": .array(values.map { .string($0) }),
            "error": .string(error),
            "options": .array(options.map(\.leafData))
        ])
    }
}

