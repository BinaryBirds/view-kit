//
//  EditViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

import Vapor
import Fluent

public protocol EditViewController: IdentifiableViewController {
    /// the associated edit form
    associatedtype EditForm: Form

    /// the name of the edit view template
    var editView: String { get }
    
    var fileUploadLimit: ByteCount { get }

    /// this is called before the form rendering happens (used both in createView and updateView)
    func beforeRender(req: Request, form: EditForm) -> EventLoopFuture<Void>
    
    func beforeInvalidRender(req: Request, form: EditForm) -> EventLoopFuture<EditForm>

    /// renders the form using the given template
    func render(req: Request, form: EditForm) -> EventLoopFuture<View>
}

public extension EditViewController {
    
    var fileUploadLimit: ByteCount { "10mb" }

    func beforeRender(req: Request, form: EditForm) -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }

    func render(req: Request, form: EditForm) -> EventLoopFuture<View> {
        return self.beforeRender(req: req, form: form)
        .flatMap { req.view.render(self.editView, EditContext(form)) }
    }

    func beforeInvalidRender(req: Request, form: EditForm) -> EventLoopFuture<EditForm> {
        req.eventLoop.future(form)
    }
}
