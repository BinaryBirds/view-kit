//
//  CreateViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol CreateViewController: EditViewController {

    /// check if there is access to create the object, if the future the server will respond with a forbidden status
    func accessCreate(req: Request) -> EventLoopFuture<Bool>
    /// renders the create form
    func createView(req: Request) throws -> EventLoopFuture<View>
    /// this will be called before the model is saved to the database during the create event
    func beforeCreate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model>
    /// create handler for the form submission
    func create(req: Request) throws -> EventLoopFuture<Response>
    /// runs after the model has been created
    func afterCreate(req: Request, form: EditForm, model: Model) -> EventLoopFuture<Response>
    /// setup the get and post create routes using the given builder
    func setupCreateRoutes(on: RoutesBuilder, as: PathComponent)
}

public extension CreateViewController {

    func beforeCreate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func accessCreate(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(true)
    }

    func createView(req: Request) throws -> EventLoopFuture<View>  {
        accessCreate(req: req).flatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            return render(req: req, form: .init())
        }
    }

    func create(req: Request) throws -> EventLoopFuture<Response> {
        accessCreate(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            try req.validateFormToken(for: "edit-form")

            let form = try EditForm(req: req)
            return form.validate(req: req).flatMap { isValid in
                guard isValid else {
                    return beforeInvalidRender(req: req, form: form).flatMap { render(req: req, form: $0).encodeResponse(for: req) }
                }
                let model = Model()
                return beforeCreate(req: req, model: model, form: form).flatMap { model in
                    form.write(to: model as! EditForm.Model)
                    return model.create(on: req.db).flatMap { afterCreate(req: req, form: form, model: model) }
                }
            }
        }
    }

    func setupCreateRoutes(on builder: RoutesBuilder, as pathComponent: PathComponent) {
        builder.get(pathComponent, use: createView)
        builder.on(.POST, pathComponent, body: .collect(maxSize: fileUploadLimit), use: create)
    }
}

public extension CreateViewController where Model.IDValue == UUID {

    func afterCreate(req: Request, form: EditForm, model: Model) -> EventLoopFuture<Response> {
        req.eventLoop.future(req.redirect(to: model.id!.uuidString))
    }
}
