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
            render(req: req, template: createView, context: [
                "formId": .string(formId),
                "formToken": .string(nonce),
                "fields": form.leafData
            ])
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
    
    func create(req: Request) throws -> EventLoopFuture<Response> {
        accessCreate(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            try req.validateFormToken(for: "create-form")

            let form = CreateForm()
            return form.initialize(req: req)
                .throwingFlatMap { try form.processInput(req: req) }
                .flatMap { form.validate(req: req) }
                .flatMap { isValid in
                    guard isValid else {
                        return beforeInvalidCreateFormRender(req: req, form: form).flatMap {
                            renderCreateForm(req: req, form: $0).encodeResponse(for: req)
                        }
                    }
                    let model = Model()
                    return beforeCreate(req: req, model: model, form: form)
                        .flatMap { model in
                            form.write(to: model as! CreateForm.Model)
                            return model.create(on: req.db).map { model }
                                .flatMap { model in
                                    form.read(from: model as! CreateForm.Model)
                                    return afterCreate(req: req, form: form, model: model)
                                }
                        }
            }
        }
    }
    
    func afterCreate(req: Request, form: CreateForm, model: Model) -> EventLoopFuture<Response> {
        renderCreateForm(req: req, form: form).encodeResponse(for: req)
    }

    func setupCreateRoutes(on builder: RoutesBuilder, as pathComponent: PathComponent) {
        builder.get(pathComponent, use: createView)
        builder.on(.POST, pathComponent, use: create)
    }
}
