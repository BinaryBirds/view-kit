//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import Vapor
@testable import ViewKit

final class ExampleEditForm: Form {

    struct Input: Decodable {
        var id: String
        var foo: String
        var bar: String
    }

    var id: String? = nil
    var foo = BasicFormField()
    var bar = BasicFormField()
    
    init() {}
    
    init(req: Request) throws {
        let context = try req.content.decode(Input.self)
        if !context.id.isEmpty {
            self.id = context.id
        }

        self.foo.value = context.foo
        self.bar.value = context.bar
    }
    
    func write(to model: ExampleModel) {
        model.foo = self.foo.value
        model.bar = Int(self.bar.value)!
    }
    
    func read(from model: ExampleModel )  {
        self.id = model.id!.uuidString
        self.foo.value = model.foo
        self.bar.value = String(model.foo)
    }

    func validate(req: Request) -> EventLoopFuture<Bool> {
        var valid = true
        if Int(self.bar.value) == nil {
            self.bar.error = "Bar is not an integer"
            valid = false
        }
        return req.eventLoop.future(valid)
    }
}
