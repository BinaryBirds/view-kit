//
//  FormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 23..
//

public final class FormField<Value: LeafDataRepresentable>: AbstractFormField {
    
    /// value of the form field
    public var value: Value?
    
    /// array of validators
    public var validators: [(FormField<Value>) -> Bool]

    public init(key: String,
                value: Value? = nil,
                name: String? = nil,
                validators: [(FormField<Value>) -> Bool] = [],
                error: String? = nil)
    {
        self.value = value
        self.validators = validators
        super.init(key: key, name: name, error: error)
    }

    /// leaf data representation of the form field
    public override var leafData: LeafData {
        .dictionary([
            "key": key,
            "name": name,
            "value": value,
            "error": error,
        ])
    }

    /// validates a form field
    public override func validate() -> Bool {
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
