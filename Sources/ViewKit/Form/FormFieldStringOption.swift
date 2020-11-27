//
//  FormFieldOption.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

/// form field option representable
public protocol FormFieldStringOptionRepresentable {
    
    /// transforms the current object to a FormFieldStringOption
    var formFieldStringOption: FormFieldStringOption { get }
}

/// selectable option
public struct FormFieldStringOption: LeafDataRepresentable {
    /// key of the option
    public let key: String
    /// title of the option
    public let label: String
    
    public init(key: String, label: String) {
        self.key = key
        self.label = label
    }

    public var leafData: LeafData {
        .dictionary([
            "key": .string(key),
            "label": .string(label),
        ])
    }
}
