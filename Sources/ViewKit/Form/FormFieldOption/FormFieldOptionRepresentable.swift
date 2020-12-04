//
//  FormFieldStringOptionRepresentable.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 04..
//

/// form field option representable
public protocol FormFieldOptionRepresentable {
    
    /// transforms the current object to a FormFieldStringOption
    var formFieldOption: FormFieldOption { get }
}
