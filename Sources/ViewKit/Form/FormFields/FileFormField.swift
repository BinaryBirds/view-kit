//
//  FileFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 09..
//

public final class FileFormField: FormFieldRepresentable {

    public var key: String
    public var value: FileValue
    public var name: String?
    public var validators: [(FileFormField) -> Bool]
    public var error: String?

    public init(key: String,
                value: FileValue = .init(),
                name: String? = nil,
                validators: [(FileFormField) -> Bool] = [],
                error: String? = nil)
    {
        self.key = key
        self.value = value
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
        value.file = req.content[key]
        value.originalKey = req.content[key+"OriginalKey"]
        if let key: String = req.content[key+"TemporaryKey"], let name: String = req.content[key+"TemporaryName"] {
            value.temporaryFile = .init(key: key, name: name)
        }
        value.delete = req.content[key+"Delete"] ?? false
    }
}
