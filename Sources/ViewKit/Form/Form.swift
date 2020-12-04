//
//  Form.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 22..
//

/// can be used to build forms
public protocol Form: AnyObject, LeafDataRepresentable {

    /// init a form
    init()

    /// init a form using an incoming request
    init(req: Request) throws
    
    func fields() -> [FormFieldInterface]

    func validateFields() -> Bool
    func validate(req: Request) -> EventLoopFuture<Bool>
}

public extension Form {

    var leafData: LeafData {
        .dictionary(fields().reduce(into: [String: LeafData]()) { $0[$1.key] = $1.leafData })
    }

    func fields() -> [FormFieldInterface] { [] }

    func validateFields() -> Bool {
        var isValid = true
        for field in fields() {
            var isFieldValid = field.validate()
            isValid = isValid && isFieldValid
        }
        return isValid
    }

    func validate(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(validateFields())
    }
}

