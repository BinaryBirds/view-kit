//
//  FormField.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 23..
//

/// a base protocol for all the form fileds
public protocol FormField: Encodable {
    
    /// error message
    var error: String? { get set }
}
