//
//  Form.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 22..
//

public protocol FormInterface: LeafDataRepresentable {
    init()

    func initialize(req: Request) throws -> EventLoopFuture<Void>
    func processInput(req: Request) throws -> EventLoopFuture<Void>
    func validate(req: Request) -> EventLoopFuture<Bool>
}

/// can be used to build forms
open class Form: FormInterface {
  
    open var message: String?

    open var leafData: LeafData {
        var dict = fields().reduce(into: [String: LeafData]()) { $0[$1.key] = $1.leafData }
        dict["message"] = .string(message)
        return .dictionary(dict)
    }

    /// init a form
    public required init() {}

    open func fields() -> [FormFieldInterface] {
        []
    }

    open func initialize(req: Request) throws -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }
    
    open func processInput(req: Request) throws -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }

    open func validateFields() -> Bool {
        var isValid = true
        for field in fields() {
            let isFieldValid = field.validate()
            isValid = isValid && isFieldValid
        }
        return isValid
    }

    open func validate(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(validateFields())
    }
}

