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
            render(req: req, template: updateView, context: [
                "formId": .string(formId),
                "formToken": .string(nonce),
                "fields": form.leafData
            ])
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
            return try find(req).flatMap { model in
                let form = UpdateForm()
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
    
    func update(req: Request) throws -> EventLoopFuture<Response> {
        accessUpdate(req: req).throwingFlatMap { hasAccess in
            guard hasAccess else {
                return req.eventLoop.future(error: Abort(.forbidden))
            }
            try req.validateFormToken(for: "update-form")

            let form = UpdateForm()
            return form.initialize(req: req)
                .throwingFlatMap { try form.processInput(req: req) }
                .flatMap { form.validate(req: req) }
                .throwingFlatMap { isValid in
                    guard isValid else {
                        return beforeInvalidUpdateFormRender(req: req, form: form)
                            .flatMap { renderUpdateForm(req: req, form: $0).encodeResponse(for: req) }
                    }
                    return try find(req)
                        .flatMap { beforeUpdate(req: req, model: $0, form: form) }
                        .flatMap { model -> EventLoopFuture<Model> in
                            form.write(to: model as! UpdateForm.Model)
                            return model.update(on: req.db).map { model }
                        }
                        .flatMap { model in
                            form.read(from: model as! UpdateForm.Model)
                            return afterUpdate(req: req, form: form, model: model)
                        }
                }
        }
    }

    func afterUpdate(req: Request, form: UpdateForm, model: Model) -> EventLoopFuture<Response> {
        renderUpdateForm(req: req, form: form).encodeResponse(for: req)
    }

    func setupUpdateRoutes(on builder: RoutesBuilder, as pathComponent: PathComponent) {
        builder.get(idPathComponent, pathComponent, use: updateView)
        builder.on(.POST, idPathComponent, pathComponent, use: update)
    }
}
