//
//  ArraySelectionFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 05..
//

public final class ArraySelectionFormField<Value: LeafDataRepresentable & Decodable>: FormFieldRepresentable {

    public var key: String
    public var name: String?
    public var error: String?
    public var values: [Value]
    public var options: [FormFieldOption]
    public var validators: [(ArraySelectionFormField<Value>) -> Bool]

    public init(key: String,
                values: [Value] = [],
                options: [FormFieldOption] = [],
                name: String? = nil,
                validators: [(ArraySelectionFormField<Value>) -> Bool] = [],
                error: String? = nil)
    {
        self.key = key
        self.values = values
        self.options = options
        self.name = name
        self.validators = validators
        self.error = error
    }

    public var leafData: LeafData {
        .dictionary([
            "key": key,
            "name": name,
            "values": values,
            "options": options.map(\.leafData),
            "error": error,
        ])
    }

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
        values = req.content[key] ?? []
    }
}
