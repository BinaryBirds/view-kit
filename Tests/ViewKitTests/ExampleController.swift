//
//  ExampleController.swift
//  ViewKitTests
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import ViewKit

final class ExampleController: AdminViewController {

    var getView: String = ""
    var listView: String = ""
    var createView: String = ""
    var updateView: String = ""
    var deleteView: String = ""
    
    typealias Model = ExampleModel
    typealias CreateForm = ExampleEditForm
    typealias UpdateForm = ExampleEditForm
    
    func find(_ req: Request) throws -> EventLoopFuture<Model> {
        req.eventLoop.future(ExampleModel(id: UUID(), foo: "foo", bar: 1))
    }

    func render(req: Request, template: String, context: LeafRenderer.Context) -> EventLoopFuture<View> {
        req.eventLoop.future(View(data: ByteBuffer(string: template)))
    }
}

