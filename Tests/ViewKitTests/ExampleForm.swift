//
//  ExampleEditForm.swift
//  ViewKitTests
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import ViewKit

final class ExampleEditForm: ModelForm {

    typealias Model = ExampleModel

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
    
    func read(from model: ExampleModel )  {
        foo.value = model.foo
        bar.value = model.bar
    }

    func write(to model: ExampleModel) {
        model.foo = foo.value!
        model.bar = bar.value!
    }
}

