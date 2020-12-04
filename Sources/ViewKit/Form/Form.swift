//
//  Form.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 22..
//

public protocol FormInterface: LeafDataRepresentable {
    init()
    init(req: Request) throws
    
    func validate(req: Request) -> EventLoopFuture<Bool>
}

/// can be used to build forms
open class Form: FormInterface {
    
    var notification: String?

    open var leafData: LeafData {
        var dict = fields().reduce(into: [String: LeafData]()) { $0[$1.key] = $1.leafData }
        dict["notification"] = .string(notification)
        return .dictionary(dict)
    }

    /// init a form
    public required init() {}

    /// init a form using an incoming request
    public required init(req: Request) throws {}

    open func fields() -> [FormFieldInterface] {
        []
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

