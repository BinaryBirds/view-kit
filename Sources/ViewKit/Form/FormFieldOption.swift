//
//  FormFieldOption.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

/// selectable option
public struct FormFieldOption: Encodable {
    /// key of the option
    public let key: String
    /// title of the option
    public let label: String
    
    public init(key: String, label: String) {
        self.key = key
        self.label = label
    }

    /// constructs a new set of yes and no options
    public static func yesNo() -> [FormFieldOption] {
        ["yes", "no"].map { .init(key: $0, label: $0.capitalized) }
    }

    /// constructs a new set of boolean options
    public static func trueFalse() -> [FormFieldOption] {
        [true, false].map { .init(key: String($0), label: String($0).capitalized) }
    }
    
    /// constructs a new set of options based on the given integer numbers
    public static func numbers(_ numbers: [Int]) -> [FormFieldOption] {
        numbers.map { .init(key: String($0), label: String($0)) }
    }
}

/// form field option representable
public protocol FormFieldOptionRepresentable {
    
    /// transforms the current object to a FormFieldOption
    var formFieldOption: FormFieldOption { get }
}
