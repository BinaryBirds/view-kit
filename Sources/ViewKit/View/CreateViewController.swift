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

    func setupCreateRoutes(routes: RoutesBuilder, on pathComponent: PathComponent)
}

public extension CreateViewController {

    func beforeCreate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func createView(req: Request) throws -> EventLoopFuture<View>  {
        self.render(req: req, form: .init())
    }

    func create(req: Request) throws -> EventLoopFuture<Response> {
        let form = try EditForm(req: req)
        return form.validate(req: req).flatMap { isValid in
            guard isValid else {
                return self.beforeInvalidRender(req: req, form: form)
                    .flatMap { self.render(req: req, form: $0).encodeResponse(for: req) }
            }
            let model = Model()
            return self.beforeCreate(req: req, model: model, form: form)
            .flatMap { model in
                form.write(to: model as! Self.EditForm.Model)
                return model.create(on: req.db)
                    .flatMap { self.afterCreate(req: req, form: form, model: model) }
            }
        }
    }
    
    func afterCreate(req: Request, form: EditForm, model: Model) -> EventLoopFuture<Response> {
        let response = req.redirect(to: model.viewIdentifier)
        return req.eventLoop.makeSucceededFuture(response)
    }
    
    func setupCreateRoutes(routes: RoutesBuilder, on pathComponent: PathComponent) {
        routes.get(pathComponent, use: self.createView)
        routes.on(.POST, pathComponent, body: .collect(maxSize: self.fileUploadLimit), use: self.create)
    }
}
