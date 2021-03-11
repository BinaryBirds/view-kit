//
//  GetViewController+Public.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 04..
//

public extension GetViewController {
    
    func accessGet(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(true)
    }

    func beforeGet(req: Request, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func get(req: Request) throws -> EventLoopFuture<Response> {
        accessGet(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            let id = try identifier(req)
            return findBy(id, on: req.db)
                .flatMap { beforeGet(req: req, model: $0) }
                .flatMap { getResponse(req: req, model: $0) }
        }
    }
    
    func getResponse(req: Request, model: Model) -> EventLoopFuture<Response> {
        render(req: req, template: getView, context: ["model": model.templateData]).encodeResponse(for: req)
    }
    
    func setupGetRoute(on builder: RoutesBuilder) {
        builder.get(idPathComponent, use: get)
    }
}
