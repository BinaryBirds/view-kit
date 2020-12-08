//
//  SelectionFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 05..
//

public final class SelectionFormField<Value: LeafDataRepresentable & Decodable>: FormFieldRepresentable {

    public var key: String
    public var name: String?
    public var error: String?
    public var value: Value?
    public var options: [FormFieldOption]
    public var validators: [(SelectionFormField<Value>) -> Bool]

    public init(key: String,
                value: Value? = nil,
                options: [FormFieldOption] = [],
                name: String? = nil,
                validators: [(SelectionFormField<Value>) -> Bool] = [],
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
    public var leafData: LeafData {
        .dictionary([
            "key": key,
            "name": name,
            "value": value,
            "options": options.map(\.leafData),
            "error": error,
        ])
    }

    /// validates a form field
    public func validate() -> Bool {
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
    
    public func process(req: Request) {
        value = req.content[key]
    }
}
