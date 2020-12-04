//
//  FormField+Validators.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 04..
//

public extension FormField where Value == String {

    func required(message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value == nil || field.value!.isEmpty {
                let message = message ?? "\(name ?? key.capitalized) is required"
                field.error = message
                return false
            }
            return true
        })
        return self
    }
    
    func length(max: Int, message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value == nil || field.value!.count > max {
                let message = message ?? "\(name ?? key.capitalized) is too long (max: \(max) characters)"
                field.error = message
                return false
            }
            return true
        })
        return self
    }
    
    func length(min: Int, message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value == nil || field.value!.count < min {
                let message = message ?? "\(name ?? key.capitalized) is too short (min: \(min) characters)"
                field.error = message
                return false
            }
            return true
        })
        return self
    }

    func alphanumerics(message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value == nil || Validator.characterSet(.alphanumerics).validate(field.value!).isFailure {
                let message = message ?? "\(name ?? key.capitalized) should be only alphanumeric characters"
                field.error = message
                return false
            }
            return true
        })
        return self
    }
    
    func email(message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value == nil || !Validator.email.validate(field.value!).isFailure {
                let message = message ?? "\(name ?? key.capitalized) should be a valid email address"
                field.error = message
                return false
            }
            return true
        })
        return self
    }
}

public extension FormField where Value == Int {
 
    func min(_ min: Int, message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value == nil || field.value! < min {
                let message = message ?? "\(name ?? key.capitalized) should be greater than \(min)"
                field.error = message
                return false
            }
            return true
        })
        return self
    }
    
    func max(_ max: Int, message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value == nil || field.value! > max {
                let message = message ?? "\(name ?? key.capitalized) should be less than \(max)"
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
