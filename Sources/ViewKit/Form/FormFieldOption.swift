//
//  FormFieldOption.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

import Foundation

/// selectable option
public struct FormFieldOption: Encodable {
    /// key of the option
    public let key: String
    /// title of the option
    public let label: String
    
    public init(key: String, label: String) {
        self.key = key
        self.label = label
    }
}

public protocol FormFieldOptionRepresentable {
    var formFieldOption: FormFieldOption { get }
}
