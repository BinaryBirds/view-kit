//
//  ExampleEditForm.swift
//  ViewKitTests
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import ViewKit

final class ExampleEditForm: ModelForm<ExampleModel> {

    struct Input: Decodable {
        var id: UUID?
        var foo: String
        var bar: Int
    }

    // MARK: - properties
    var foo = FormField<String>(key: "foo").required().length(max: 250)
    var bar = FormField<Int>(key: "bar").min(300).max(900)

    /// list fields
    override func fields() -> [FormFieldInterface] {
        [foo, bar]
    }

    // MARK: - methods

    required init() {
        super.init()
    }

    required init(req: Request) throws {
        try super.init(req: req)

        let context = try req.content.decode(Input.self)
        modelId = context.id
        foo.value = context.foo
        bar.value = context.bar
    }
    
    override func read(from model: ExampleModel )  {
        modelId = model.id
        foo.value = model.foo
        bar.value = model.bar
    }

    override func write(to model: ExampleModel) {
        model.foo = foo.value!
        model.bar = bar.value!
    }
}

