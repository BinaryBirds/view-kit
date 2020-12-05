//
//  ModelForm.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 11. 19..
//

public protocol ModelFormInterface: FormInterface {
    
    associatedtype Model: Fluent.Model

    var modelId: Model.IDValue? { get set }
    func read(from: Model)
    func write(to: Model)
}

/// can be used to build forms with associated models
open class ModelForm<Model: Fluent.Model>: Form, ModelFormInterface {
    
    open override var leafData: LeafData {
        var dict = super.leafData.dictionary!
        dict["modelId"] = modelId?.encodeToLeafData()
        return .dictionary(dict)
    }

    public required init() {
        super.init()
    }

    /// raw string identifier of the associated model
    open var modelId: Model.IDValue?

    /// loads the form field values using the model
    open func read(from: Model) {
        
    }
    
    /// saves the form field values into the model
    open func write(to: Model) {
        
    }
}
