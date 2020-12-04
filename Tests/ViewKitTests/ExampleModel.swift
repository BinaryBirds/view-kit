//
//  ExampleModel.swift
//  ViewKitTests
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import ViewKit

final class ExampleModel: Model {

    static let schema = "examples"
    
    struct FieldKeys {
        static var foo: FieldKey { "foo" }
        static var bar: FieldKey { "bar" }
    }

    @ID() var id: UUID?
    @Field(key: FieldKeys.foo) var foo: String
    @Field(key: FieldKeys.bar) var bar: Int

    init() { }
    
    init(id: UUID? = nil, foo: String, bar: Int) {
        self.id = id
        self.foo = foo
        self.bar = bar
    }
}

extension ExampleModel: LeafDataRepresentable {

    var leafData: LeafData {
        .dictionary([
            "id": id,
            "foo": foo,
            "bar": bar,
        ])
    }
    
}
