//
//  ModelForm.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 11. 19..
//

public protocol ModelForm: Form {
    
    associatedtype Model: Fluent.Model

    var modelId: Model.IDValue? { get set }

    func read(from: Model)
    func write(to: Model)

    func willSave(req: Request, model: Model) -> EventLoopFuture<Void>
    func didSave(req: Request, model: Model) -> EventLoopFuture<Void>
}

/// can be used to build forms with associated models
public extension ModelForm {

    var leafData: LeafData {
        .dictionary([
            "modelId": modelId?.encodeToLeafData() ?? .string(nil),
            "fields": fieldsLeafData,
            "notification": .string(notification)
        ])
    }
    
    func willSave(req: Request, model: Model) -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }

    func didSave(req: Request, model: Model) -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }
}
