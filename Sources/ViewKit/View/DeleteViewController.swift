//
//  DeleteViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

import Vapor
import Fluent

public protocol DeleteViewController: IdentifiableViewController {
    /// this will be called before the model is deleted
    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model>
    /// deletes a model from the database
    func delete(req: Request) throws -> EventLoopFuture<String>
    
    func setupDeleteRoute(routes: RoutesBuilder)
}

public extension DeleteViewController {

    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func delete(req: Request) throws -> EventLoopFuture<String> {
        try self.find(req)
            .flatMap { self.beforeDelete(req: req, model: $0) }
            .flatMap { model in model.delete(on: req.db).transform(to: model.viewIdentifier) }
    }
    
    func setupDeleteRoute(routes: RoutesBuilder, on pathComponent: PathComponent) {
        routes.post(self.idPathComponent, pathComponent, use: self.delete)
    }
}
