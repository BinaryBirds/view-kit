//
//  DeleteViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol DeleteViewController: IdentifiableViewController {
    /// this will be called before the model is deleted
    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model>
    /// deletes a model from the database
    func delete(req: Request) throws -> EventLoopFuture<String>
    
    func setupDeleteRoute(on: RoutesBuilder, as: PathComponent)
}

public extension DeleteViewController {

    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func setupDeleteRoute(on builder: RoutesBuilder, as pathComponent: PathComponent) {
        builder.post(idPathComponent, pathComponent, use: delete)
    }
}

public extension DeleteViewController where Model.IDValue == UUID {
    func delete(req: Request) throws -> EventLoopFuture<String> {
        try find(req)
            .flatMap { beforeDelete(req: req, model: $0) }
            .flatMap { model in model.delete(on: req.db).transform(to: model.id!.uuidString) }
    }

}
