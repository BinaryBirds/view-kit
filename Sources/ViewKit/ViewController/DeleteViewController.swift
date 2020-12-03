//
//  DeleteViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

extension EventLoopFuture {
    
}
public protocol DeleteViewController: IdentifiableViewController {
    /// the view used to render the delete form
    var deleteView: String { get }
    
    /// check if there is access to delete the object, if the future the server will respond with a forbidden status
    func accessDelete(req: Request) -> EventLoopFuture<Bool>
    /// this will be called before the model is deleted
    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model>
    /// deletes a model from the database
    func delete(req: Request) throws -> EventLoopFuture<Response>
    /// this method will be called after a succesful deletion
    func afterDelete(req: Request, model: Model) -> EventLoopFuture<Response>
    /// setup the get and post routes for the delete controller
    func setupDeleteRoutes(on: RoutesBuilder, as: PathComponent)
}

public extension DeleteViewController {

    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func accessDelete(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(true)
    }

    func deleteView(req: Request) throws -> EventLoopFuture<View>  {
        accessDelete(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            let formId = UUID().uuidString
            let nonce = req.generateNonce(for: "delete-form", id: formId)

            return try find(req).flatMap { model in
                return req.leaf.render(template: deleteView, context: [
                    "formId": .string(formId),
                    "formToken": .string(nonce),
                    "model": model.leafData,
                ])
            }
        }
    }

    func afterDelete(req: Request, model: Model) -> EventLoopFuture<Response> {
        req.eventLoop.future(Response(status: .ok, version: req.version))
    }
    
    func setupDeleteRoutes(on builder: RoutesBuilder, as pathComponent: PathComponent) {
        builder.get(idPathComponent, pathComponent, use: deleteView)
        builder.post(idPathComponent, pathComponent, use: delete)
    }
}

public extension DeleteViewController where Model.IDValue == UUID {

    func delete(req: Request) throws -> EventLoopFuture<Response> {
        accessDelete(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            try req.validateFormToken(for: "delete-form")

            return try find(req).flatMap { beforeDelete(req: req, model: $0) }
                .flatMap { model in model.delete(on: req.db).flatMap { afterDelete(req: req, model: model) } }
        }
        
    }
}
