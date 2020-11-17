//
//  CreateViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol CreateViewController: EditViewController {

    /// renders the create form
    func createView(req: Request) throws -> EventLoopFuture<View>
    /// this will be called before the model is saved to the database during the create event
    func beforeCreate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model>
    /// create handler for the form submission
    func create(req: Request) throws -> EventLoopFuture<Response>
    
    func afterCreate(req: Request, form: EditForm, model: Model) -> EventLoopFuture<Response>

    func setupCreateRoutes(on: RoutesBuilder, as: PathComponent)
}

public extension CreateViewController {

    func beforeCreate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func createView(req: Request) throws -> EventLoopFuture<View>  {
        render(req: req, form: .init())
    }

    func create(req: Request) throws -> EventLoopFuture<Response> {
        let context = try req.content.decode(FormInput.self)
        try req.useNonce(for: "edit-form", id: context.formId, token: context.formToken)

        let form = try EditForm(req: req)
        return form.validate(req: req).flatMap { isValid in
            guard isValid else {
                return beforeInvalidRender(req: req, form: form)
                    .flatMap { render(req: req, form: $0).encodeResponse(for: req) }
            }
            let model = Model()
            return beforeCreate(req: req, model: model, form: form)
            .flatMap { model in
                form.write(to: model as! EditForm.Model)
                return model.create(on: req.db)
                    .flatMap { afterCreate(req: req, form: form, model: model) }
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
