//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import Vapor
@testable import ViewKit

final class ExampleEditForm: ModelForm {

    struct Input: Decodable {
        var id: String
        var foo: String
        var bar: String
    }

    var modelId: String? = nil
    var foo = StringFormField()
    var bar = StringFormField()
    
    init() {}
    
    init(req: Request) throws {
        let context = try req.content.decode(Input.self)
        if !context.id.isEmpty {
            modelId = context.id
        }

        foo.value = context.foo
        bar.value = context.bar
    }
    
    func write(to model: ExampleModel) {
        model.foo = foo.value
        model.bar = Int(bar.value)!
    }
    
    func read(from model: ExampleModel )  {
        modelId = model.id!.uuidString
        foo.value = model.foo
        bar.value = String(model.foo)
    }

    func validate(req: Request) -> EventLoopFuture<Bool> {
        var valid = true
        if Int(bar.value) == nil {
            bar.error = "Bar is not an integer"
            valid = false
        }
        return req.eventLoop.future(valid)
    }
    
    var leafData: LeafData {
        .dictionary([
            "id": .string(modelId),
            "foo": foo.leafData,
            "bar": bar.leafData,
        ])
    }
}
