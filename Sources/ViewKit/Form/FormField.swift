//
//  FormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 23..
//

/// a base protocol for all the form fileds
open class FormField<Value: LeafDataRepresentable>: FormFieldInterface {

    /// key of the form field
    public var key: String

    /// value of the form field
    public var value: Value?

    /// name of the form field
    public var name: String?
    
    /// options
    public var options: [FormFieldOption]
    
    /// array of validators
    public var validators: [(FormField<Value>) -> Bool]

    /// error message
    public var error: String?

    public init(key: String,
                value: Value? = nil,
                options: [FormFieldOption] = [],
                name: String? = nil,
                validators: [(FormField<Value>) -> Bool] = [],
                error: String? = nil)
    {
        self.key = key
        self.value = value
        self.options = options
        self.name = name
        self.validators = validators
        self.error = error
    }

    /// leaf data representation of the form field
    open var leafData: LeafData {
        .dictionary([
            "key": key,
            "name": name,
            "value": value,
            "options": options.map(\.leafData),
            "error": error,
        ])
    }

    /// validates a form field
    open func validate() -> Bool {
        /// clean previous error messages
        error = nil
        /// run validators again...
        var isValid = true
        for validator in validators {
            /// stop if a field was already invalid
            isValid = isValid && validator(self)
        }
        return isValid
    }
}
