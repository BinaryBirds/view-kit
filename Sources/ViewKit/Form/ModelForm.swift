//
//  ModelForm.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 11. 19..
//

/// can be used to build forms with associated models
public protocol ModelForm: Form {

    /// the associated model
    associatedtype Model: Fluent.Model
    
    /// raw string identifier of the associated model
    var modelId: String? { get }
    
    /// loads the form field values using the model
    func read(from: Model)
    
    /// saves the form field values into the model
    func write(to: Model)
}
