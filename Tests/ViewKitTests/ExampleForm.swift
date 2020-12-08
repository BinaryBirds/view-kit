//
//  ExampleEditForm.swift
//  ViewKitTests
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import ViewKit

final class ExampleEditForm: ModelForm {

    typealias Model = ExampleModel

    struct Input: Decodable {
        var id: UUID?
        var foo: String
        var bar: Int
    }

    // MARK: - properties
    var modelId: UUID?
    var foo = FormField<String>(key: "foo").required().length(max: 250)
    var bar = FormField<Int>(key: "bar").min(300).max(900)
    var notification: String?

    var fields: [FormFieldRepresentable] {
        [foo, bar]
    }

    // MARK: - methods

    init() {}

    func processInput(req: Request) throws -> EventLoopFuture<Void> {
        let context = try req.content.decode(Input.self)
        modelId = context.id
        foo.value = context.foo
        bar.value = context.bar

        return req.eventLoop.future()
    }
    
    func read(from model: ExampleModel )  {
        modelId = model.id
        foo.value = model.foo
        bar.value = model.bar
    }

    func write(to model: ExampleModel) {
        model.foo = foo.value!
        model.bar = bar.value!
    }
}

