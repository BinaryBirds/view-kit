//
//  FormFieldOption.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

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

public extension FormFieldStringOption {
    /// constructs a new set of yes and no options
    static func yesNo() -> [FormFieldStringOption] {
        ["yes", "no"].map { .init(key: $0, label: $0.capitalized) }
    }

    /// constructs a new set of boolean options
    static func trueFalse() -> [FormFieldStringOption] {
        [true, false].map { .init(key: String($0), label: String($0).capitalized) }
    }
    
    /// constructs a new set of options based on the given integer numbers
    static func numbers(_ numbers: [Int]) -> [FormFieldStringOption] {
        numbers.map { .init(key: String($0), label: String($0)) }
    }
}

/// form field option representable
public protocol FormFieldStringOptionRepresentable {
    
    /// transforms the current object to a FormFieldStringOption
    var formFieldStringOption: FormFieldStringOption { get }
}
