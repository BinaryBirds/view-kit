//
//  UpdateViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

import Vapor
import Fluent

public protocol UpdateViewController: EditViewController {
    /// renders the update form filled with the entity
    func updateView(req: Request) throws -> EventLoopFuture<View>
    /// this will be called before the model is updated
    func beforeUpdate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model>
    /// update handler for the form submission
    func update(req: Request) throws -> EventLoopFuture<Response>
    
    func afterUpdate(req: Request, form: EditForm, model: Model) -> EventLoopFuture<Response>
    
    func setupUpdateRoutes(routes: RoutesBuilder)
}

public extension UpdateViewController {
    
    func beforeUpdate(req: Request, model: Model, form: EditForm) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }
    
    func updateView(req: Request) throws -> EventLoopFuture<View>  {
        try self.find(req).flatMap { model in
            let form = EditForm()
            form.read(from: model as! Self.EditForm.Model)
            return self.render(req: req, form: form)
        }
    }
    
    func update(req: Request) throws -> EventLoopFuture<Response> {
        let form = try EditForm(req: req)
        return form.validate(req: req).flatMap { isValid in
            guard isValid else {
                return self.beforeInvalidRender(req: req, form: form)
                    .flatMap { self.render(req: req, form: $0).encodeResponse(for: req) }
            }
            do {
                return try self.find(req)
                    .flatMap { self.beforeUpdate(req: req, model: $0, form: form) }
                    .flatMap { model -> EventLoopFuture<Model> in
                        form.write(to: model as! Self.EditForm.Model)
                        return model.update(on: req.db).map { model }
                }
                .flatMap { model in
                    form.read(from: model as! Self.EditForm.Model)
                    return self.afterUpdate(req: req, form: form, model: model)
                }
            }
            catch {
                return req.eventLoop.future(error: error)
            }
        }
    }

    func afterUpdate(req: Request, form: EditForm, model: Model) -> EventLoopFuture<Response> {
        self.render(req: req, form: form).encodeResponse(for: req)
    }

    func setupUpdateRoutes(routes: RoutesBuilder) {
        routes.get(self.idPathComponent, use: self.updateView)
        routes.on(.POST, self.idPathComponent, body: .collect(maxSize: self.fileUploadLimit), use: self.update)
    }
}
