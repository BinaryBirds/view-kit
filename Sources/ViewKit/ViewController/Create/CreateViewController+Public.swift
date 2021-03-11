//
//  CreateViewController+Public.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public extension CreateViewController {

    func beforeInvalidCreateFormRender(req: Request, form: CreateForm) -> EventLoopFuture<CreateForm> {
        req.eventLoop.future(form)
    }

    func beforeCreateFormRender(req: Request, form: CreateForm) -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }

    func renderCreateForm(req: Request, form: CreateForm) -> EventLoopFuture<View> {
        let formId = UUID().uuidString
        let nonce = req.generateNonce(for: "create-form", id: formId)

        return beforeCreateFormRender(req: req, form: form).flatMap {
            var templateData = form.templateData.dictionary!
            templateData["formId"] = .string(formId)
            templateData["formToken"] = .string(nonce)
            return render(req: req, template: createView, context: .init(templateData))
        }
    }

    func accessCreate(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(true)
    }

    func createView(req: Request) throws -> EventLoopFuture<View>  {
        accessCreate(req: req).flatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            let form = CreateForm()
            return form.initialize(req: req).flatMap {
                renderCreateForm(req: req, form: form)
            }
        }
    }

    func beforeCreate(req: Request, model: Model, form: CreateForm) -> EventLoopFuture<Model> {
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
     before create we can still alter the model
     create
     call didSave model
     after create we can alter the model
     read the form with using new model
     call save form
     createResponse (render the form)
     */
    func create(req: Request) throws -> EventLoopFuture<Response> {
        accessCreate(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            try req.validateFormToken(for: "create-form")

            let form = CreateForm()
            return form.initialize(req: req)
                .flatMap { form.process(req: req) }
                .flatMap { form.validate(req: req) }
                .flatMap { isValid in
                    guard isValid else {
                        return beforeInvalidCreateFormRender(req: req, form: form).flatMap {
                            renderCreateForm(req: req, form: $0).encodeResponse(for: req)
                        }
                    }
                    let model = Model()
                    form.write(to: model as! CreateForm.Model)

                    return form.willSave(req: req, model: model as! CreateForm.Model)
                        .flatMap { beforeCreate(req: req, model: model, form: form) }
                        .flatMap { model in model.create(on: req.db).map { model } }
                        .flatMap { model in form.didSave(req: req, model: model as! CreateForm.Model ).map { model } }
                        .flatMap { afterCreate(req: req, form: form, model: $0) }
                        .map { model in form.read(from: model as! CreateForm.Model); return model; }
                        .flatMap { model in form.save(req: req).map { model } }
                        .flatMap { createResponse(req: req, form: form, model: $0) }
            }
        }
    }
    
    func afterCreate(req: Request, form: CreateForm, model: Model) -> EventLoopFuture<Model> {
        req.eventLoop.future(model)
    }

    func createResponse(req: Request, form: CreateForm, model: Model) -> EventLoopFuture<Response> {
        renderCreateForm(req: req, form: form).encodeResponse(for: req)
    }

    func setupCreateRoutes(on builder: RoutesBuilder, as pathComponent: PathComponent) {
        builder.get(pathComponent, use: createView)
        builder.on(.POST, pathComponent, use: create)
    }
}
