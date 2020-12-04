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

    func getView(req: Request) throws -> EventLoopFuture<View> {
        accessGet(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            return try find(req)
                .flatMap { beforeGet(req: req, model: $0) }
                .flatMap { render(req: req, template: getView, context: ["model": $0.leafData]) }
        }
    }
    
    func setupGetRoute(on builder: RoutesBuilder) {
        builder.get(idPathComponent, use: getView)
    }
}
