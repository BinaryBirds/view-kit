//
//  DeleteViewController+Public.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public extension DeleteViewController {

    func accessDelete(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(true)
    }

    func deleteView(req: Request) throws -> EventLoopFuture<View>  {
        accessDelete(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            let id = try identifier(req)
            let formId = UUID().uuidString
            let nonce = req.generateNonce(for: "delete-form", id: formId)

            return findBy(id, on: req.db).flatMap { model in
                render(req: req, template: deleteView, context: [
                    "formId": .string(formId),
                    "formToken": .string(nonce),
                    "model": model.templateData,
                ])
            }
        }
    }

    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }
    
    func delete(req: Request) throws -> EventLoopFuture<Response> {
        accessDelete(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            try req.validateFormToken(for: "delete-form")

            let id = try identifier(req)
            return findBy(id, on: req.db)
                .flatMap { beforeDelete(req: req, model: $0) }
                .flatMap { model in model.delete(on: req.db).map { model } }
                .flatMap { afterDelete(req: req, model: $0) } }
                .flatMap { deleteResponse(req: req, model: $0) }
    }

    func afterDelete(req: Request, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func deleteResponse(req: Request, model: Model) -> EventLoopFuture<Response> {
        req.eventLoop.future(Response(status: .ok, version: req.version))
    }
    
    func setupDeleteRoutes(on builder: RoutesBuilder, as pathComponent: PathComponent) {
        builder.get(idPathComponent, pathComponent, use: deleteView)
        builder.post(idPathComponent, pathComponent, use: delete)
    }
}
