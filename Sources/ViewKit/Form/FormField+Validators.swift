//
//  FormField+Validators.swift
//  
//
//  Created by Tibor Bodecs on 2020. 12. 04..
//

public extension FormField where Value == String {

    func required(message: String? = nil) -> Self {
        validators.append({ [unowned self] field -> Bool in
            if field.value.isEmpty {
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
            if field.value.count > max {
                let message = message ?? "\(name ?? key.capitalized) is too long (max: \(max) characters)"
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
            if field.value < min {
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
            if field.value > max {
                let message = message ?? "\(name ?? key.capitalized) should be less than \(max)"
                field.error = message
                return false
            }
            return true
        })
        return self
    }
}
