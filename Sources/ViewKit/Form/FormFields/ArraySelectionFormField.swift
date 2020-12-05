//
//  ArraySelectionFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 05..
//

public final class ArraySelectionFormField<Value: LeafDataRepresentable>: AbstractFormField {

    /// value of the form field
    public var values: [Value]

    /// options
    public var options: [FormFieldOption]
    
    /// array of validators
    public var validators: [(ArraySelectionFormField<Value>) -> Bool]


    public init(key: String,
                values: [Value] = [],
                options: [FormFieldOption] = [],
                name: String? = nil,
                validators: [(ArraySelectionFormField<Value>) -> Bool] = [],
                error: String? = nil)
    {
        self.values = values
        self.options = options
        self.validators = validators

        super.init(key: key, name: name, error: error)
    }

    /// leaf data representation of the form field
    public override var leafData: LeafData {
        .dictionary([
            "key": key,
            "name": name,
            "values": values,
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
