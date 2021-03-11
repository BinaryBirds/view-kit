//
//  FormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 23..
//

public final class FormField<Value: TemplateDataRepresentable & Decodable>: FormFieldRepresentable {

    public var key: String
    public var value: Value?
    public var name: String?
    public var validators: [(FormField<Value>) -> Bool]
    public var error: String?

    public init(key: String,
                value: Value? = nil,
                name: String? = nil,
                validators: [(FormField<Value>) -> Bool] = [],
                error: String? = nil)
    {
        self.key = key
        self.value = value
        self.name = name
        self.validators = validators
        self.error = error
    }

    /// template data representation of the form field
    public var templateData: TemplateData {
        .dictionary([
            "key": key,
            "name": name,
            "value": value,
            "error": error,
        ])
    }

    /// validates a form field
    public func validate() -> Bool {
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
    
    public func process(req: Request) {
        value = try? req.content.get(Value.self, at: key)
    }
}
