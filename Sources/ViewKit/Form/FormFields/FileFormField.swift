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
        
        let originalKey = key+"OriginalKey"
        let tempKey = key+"TemporaryKey"
        let tempNameKey = key+"TemporaryName"
        let deleteKey = key+"Delete"

        value.file = try? req.content.get(File.self, at: key)
        value.originalKey = try? req.content.get(String.self, at: originalKey)
        if
            let key = try? req.content.get(String.self, at: tempKey),
            let name = try? req.content.get(String.self, at: tempNameKey)
        {
            value.temporaryFile = .init(key: key, name: name)
        }
        value.delete = (try? req.content.get(Bool.self, at: deleteKey)) ?? false
    }
}

public extension FileFormField {
    
    func required(message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if
                (field.value.temporaryFile == nil && field.value.delete) ||
                (field.value.temporaryFile == nil && field.value.originalKey == nil)
            {
                let message = message ?? "\(name ?? key.capitalized) is required"
                field.error = message
                return false
            }
            return true
        })
        return self
    }
}
