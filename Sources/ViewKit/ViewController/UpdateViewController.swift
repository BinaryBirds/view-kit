//
//  UpdateViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol UpdateViewController: EditViewController {
    
    /// check if there is access to update the object, if the future the server will respond with a forbidden status
    func accessUpdate(req: Request) -> EventLoopFuture<Bool>
    /// renders the update form filled with the entity
    func updateView(req: Request) throws -> EventLoopFuture<View>
    /// this will be called before the model is updated
    func beforeUpdate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model>
    /// update handler for the form submission
    func update(req: Request) throws -> EventLoopFuture<Response>
    /// runs after the model was updated
    func afterUpdate(req: Request, form: EditForm, model: Model) -> EventLoopFuture<Response>
    /// setup update routes using the route builder
    func setupUpdateRoutes(on: RoutesBuilder)
}

public extension UpdateViewController {
    
    func beforeUpdate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func accessUpdate(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(true)
    }
    
    func updateView(req: Request) throws -> EventLoopFuture<View>  {
        accessUpdate(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            return try find(req).flatMap { model in
                let form = EditForm()
                form.read(from: model as! EditForm.Model)
                return render(req: req, form: form)
            }
        }
    }
    
    func update(req: Request) throws -> EventLoopFuture<Response> {
        accessUpdate(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            try req.validateFormToken(for: "edit-form")

            let form = try EditForm(req: req)
            return form.validate(req: req).throwingFlatMap { isValid in
                guard isValid else {
                    return beforeInvalidRender(req: req, form: form)
                        .flatMap { render(req: req, form: $0).encodeResponse(for: req) }
                }
                return try find(req)
                    .flatMap { beforeUpdate(req: req, model: $0, form: form) }
                    .flatMap { model -> EventLoopFuture<Model> in
                        form.write(to: model as! EditForm.Model)
                        return model.update(on: req.db).map { model }
                }
                .flatMap { model in
                    form.read(from: model as! EditForm.Model)
                    return afterUpdate(req: req, form: form, model: model)
                }
            }
        }
    }

    func afterUpdate(req: Request, form: EditForm, model: Model) -> EventLoopFuture<Response> {
        render(req: req, form: form).encodeResponse(for: req)
    }

    func setupUpdateRoutes(on builder: RoutesBuilder) {
        builder.get(idPathComponent, use: updateView)
        builder.on(.POST, idPathComponent, body: .collect(maxSize: fileUploadLimit), use: update)
    }
}
