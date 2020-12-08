//
//  UpdateViewController+Public.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 04..
//

public extension UpdateViewController {
    
    func beforeInvalidUpdateFormRender(req: Request, form: UpdateForm) -> EventLoopFuture<UpdateForm> {
        req.eventLoop.future(form)
    }

    func beforeUpdateFormRender(req: Request, form: UpdateForm) -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }

    func renderUpdateForm(req: Request, form: UpdateForm) -> EventLoopFuture<View> {
        let formId = UUID().uuidString
        let nonce = req.generateNonce(for: "update-form", id: formId)

        return beforeUpdateFormRender(req: req, form: form).flatMap {
            var leafData = form.leafData.dictionary!
            leafData["formId"] = .string(formId)
            leafData["formToken"] = .string(nonce)
            return render(req: req, template: updateView, context: .init(leafData))
        }
    }

    func accessUpdate(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(true)
    }
    
    func updateView(req: Request) throws -> EventLoopFuture<View>  {
        accessUpdate(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            let id = try identifier(req)
            let form = UpdateForm()
            form.modelId = (id as! UpdateForm.Model.IDValue)
            return findBy(id, on: req.db).flatMap { model in
                return form.initialize(req: req).flatMap {
                    form.read(from: model as! UpdateForm.Model)
                    return renderUpdateForm(req: req, form: form)
                }
            }
        }
    }
    
    func beforeUpdate(req: Request, model: Model, form: UpdateForm) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }
    
    /*
     FLOW:
     ----
     check access
     validate incoming from with token
     create form
     initialize form
     process input form
     validate form
     if invalid:
        -> before invalid render we can still alter the form!
        -> render
     else:
     create / find the model
     write the form content to the model
     before update we can still alter the model
     update
     save form
     after create we can alter the model
     read the form with using new model
     createResponse (render the form)
     */
    func update(req: Request) throws -> EventLoopFuture<Response> {
        accessUpdate(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            try req.validateFormToken(for: "update-form")

            let id = try identifier(req)
            let form = UpdateForm()
            form.modelId = (id as! UpdateForm.Model.IDValue)

            return form.initialize(req: req)
                .flatMap { form.process(req: req) }
                .flatMap { form.validate(req: req) }
                .throwingFlatMap { isValid in
                    guard isValid else {
                        return beforeInvalidUpdateFormRender(req: req, form: form)
                            .flatMap { renderUpdateForm(req: req, form: $0).encodeResponse(for: req) }
                    }
                    return findBy(id, on: req.db)
                        .map { form.write(to: $0 as! UpdateForm.Model); return $0; }
                        .flatMap { beforeUpdate(req: req, model: $0, form: form) }
                        .flatMap { model in model.update(on: req.db).map { model } }
                        .flatMap { model in form.didSave(req: req, model: model as! UpdateForm.Model).map { model } }
                        .flatMap { afterUpdate(req: req, form: form, model: $0) }
                        .map { form.read(from: $0 as! UpdateForm.Model); return $0; }
                        .flatMap { model in form.save(req: req).map { model } }
                        .flatMap { updateResponse(req: req, form: form, model: $0) }
                }
        }
    }

    func afterUpdate(req: Request, form: UpdateForm, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }
    
    func updateResponse(req: Request, form: UpdateForm, model: Model) -> EventLoopFuture<Response> {
        renderUpdateForm(req: req, form: form).encodeResponse(for: req)
    }

    func setupUpdateRoutes(on builder: RoutesBuilder, as pathComponent: PathComponent) {
        builder.get(idPathComponent, pathComponent, use: updateView)
        builder.on(.POST, idPathComponent, pathComponent, use: update)
    }
}
