//
//  DeleteViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol DeleteViewController: IdentifiableViewController {

    var deleteView: String { get }

    /// this will be called before the model is deleted
    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model>
    /// deletes a model from the database
    func delete(req: Request) throws -> EventLoopFuture<Response>
    
    /// this method will be called after a succesful deletion
    func afterDelete(req: Request, model: Model) -> EventLoopFuture<Response>
    
    func setupDeleteRoutes(on: RoutesBuilder, as: PathComponent)
}

public extension DeleteViewController {

    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func setupDeleteRoutes(on builder: RoutesBuilder, as pathComponent: PathComponent) {
        builder.get(idPathComponent, pathComponent, use: deleteView)
        builder.post(idPathComponent, pathComponent, use: delete)
    }

    func deleteView(req: Request) throws -> EventLoopFuture<View>  {
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

    func afterDelete(req: Request, model: Model) -> EventLoopFuture<Response> {
        let separator = "/"
        let suffix = req.url.path.hasSuffix(separator) ? separator : ""
        let newPath = separator + req.url.path.split(separator: Character(separator)).dropLast(2).joined(separator: separator) + suffix
        let response = req.redirect(to: newPath)
        return req.eventLoop.makeSucceededFuture(response)
    }
}

public extension DeleteViewController where Model.IDValue == UUID {

    func delete(req: Request) throws -> EventLoopFuture<Response> {
        let context = try req.content.decode(FormInput.self)
        try req.useNonce(for: "delete-form", id: context.formId, token: context.formToken)

        return try find(req)
            .flatMap { beforeDelete(req: req, model: $0) }
            .flatMap { model in model.delete(on: req.db).flatMap { afterDelete(req: req, model: model) } }
    }
}
