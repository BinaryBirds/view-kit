//
//  AbstractFormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 05..
//

open class AbstractFormField {

    /// key of the form field
    public var key: String

    /// name of the form field
    public var name: String?

    /// error message
    public var error: String?

    public init(key: String, name: String? = nil, error: String? = nil) {
        self.key = key
        self.name = name
        self.error = error
    }

    /// leaf data representation of the form field
    open var leafData: LeafData {
        .dictionary([
            "key": key,
            "name": name,
            "error": error,
        ])
    }

    /// validates a form field
    open func validate() -> Bool {
        true
    }
}
