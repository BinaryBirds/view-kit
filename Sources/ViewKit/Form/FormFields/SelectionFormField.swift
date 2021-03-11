//
//  SelectionFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 05..
//

public final class SelectionFormField<Value: TemplateDataRepresentable & Decodable>: FormFieldRepresentable {

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

    /// template data representation of the form field
    public var templateData: TemplateData {
        .dictionary([
            "key": key,
            "name": name,
            "value": value,
            "options": options.map(\.templateData),
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
        value = try? req.content.get(Value.self, at: key)
    }
}

public extension SelectionFormField where Value == String {

    func required(message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value != nil {
                let message = message ?? "\(name ?? key.capitalized) is required"
                field.error = message
                return false
            }
            return true
        })
        return self
    }

    func contains(_ values: [String], message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value == nil || !values.contains(field.value!) {
                let message = message ?? "\(name ?? key.capitalized) is an invalid value"
                field.error = message
                return false
            }
            return true
        })
        return self
    }
}

public extension SelectionFormField where Value == Int {

    func required(message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value != nil {
                let message = message ?? "\(name ?? key.capitalized) is required"
                field.error = message
                return false
            }
            return true
        })
        return self
    }
    
    func contains(_ values: [Int], message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value == nil || !values.contains(field.value!) {
                let message = message ?? "\(name ?? key.capitalized) is an invalid value"
                field.error = message
                return false
            }
            return true
        })
        return self
    }
}

