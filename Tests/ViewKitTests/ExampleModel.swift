//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import Vapor
import Fluent
@testable import ViewKit

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

extension ExampleModel: ViewContextRepresentable {

    struct ViewContext: Encodable {
        var id: String
        var foo: String
        var bar: Int

        init(model: ExampleModel) {
            self.id = model.id!.uuidString
            self.foo = model.foo
            self.bar = model.bar
        }
    }

    var viewIdentifier: String { self.id!.uuidString }
    var viewContext: ViewContext { .init(model: self) }
}
