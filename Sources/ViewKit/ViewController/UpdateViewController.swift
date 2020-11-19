//
//  UpdateViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol UpdateViewController: EditViewController {
    /// renders the update form filled with the entity
    func updateView(req: Request) throws -> EventLoopFuture<View>
    /// this will be called before the model is updated
    func beforeUpdate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model>
    /// update handler for the form submission
    func update(req: Request) throws -> EventLoopFuture<Response>
    
    func afterUpdate(req: Request, form: EditForm, model: Model) -> EventLoopFuture<Response>
    
    func setupUpdateRoutes(on: RoutesBuilder)
}

public extension UpdateViewController {
    
    func beforeUpdate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }
    
    func updateView(req: Request) throws -> EventLoopFuture<View>  {
        try find(req).flatMap { model in
            let form = EditForm()
            form.read(from: model as! EditForm.Model)
            return render(req: req, form: form)
        }
    }
    
    func update(req: Request) throws -> EventLoopFuture<Response> {
        try req.validateFormToken(for: "edit-form")

        let form = try EditForm(req: req)
        return form.validate(req: req).flatMap { isValid in
            guard isValid else {
                return beforeInvalidRender(req: req, form: form)
                    .flatMap { render(req: req, form: $0).encodeResponse(for: req) }
            }
            do {
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
            catch {
                return req.eventLoop.future(error: error)
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
