//
//  SelectionFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 05..
//

public final class SelectionFormField<Value: LeafDataRepresentable>: AbstractFormField {

    /// value of the form field
    public var value: Value?

    /// options
    public var options: [FormFieldOption]
    
    /// array of validators
    public var validators: [(SelectionFormField<Value>) -> Bool]


    public init(key: String,
                value: Value? = nil,
                options: [FormFieldOption] = [],
                name: String? = nil,
                validators: [(SelectionFormField<Value>) -> Bool] = [],
                error: String? = nil)
    {
        self.value = value
        self.options = options
        self.validators = validators

        super.init(key: key, name: name, error: error)
    }

    /// leaf data representation of the form field
    public override var leafData: LeafData {
        .dictionary([
            "key": key,
            "name": name,
            "value": value,
            "options": options.map(\.leafData),
            "error": error,
        ])
    }

    /// validates a form field
    public override func validate() -> Bool {
        /// clean prevpublic override error messages
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
