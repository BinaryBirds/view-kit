//
//  Form.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 22..
//

public protocol Form: AnyObject, LeafDataRepresentable {

    var fields: [AbstractFormField] { get }
    var fieldsLeafData: LeafData { get }
    var notification: String? { get set }

    init()

    func initialize(req: Request) -> EventLoopFuture<Void>
    func processInput(req: Request) throws -> EventLoopFuture<Void>
    func validate(req: Request) -> EventLoopFuture<Bool>
    func save(req: Request) -> EventLoopFuture<Void>
}

public extension Form {
    
    var fields: [AbstractFormField] { [] }

    var fieldsLeafData: LeafData {
        .dictionary(fields.reduce(into: [String: LeafData]()) { $0[$1.key] = $1.leafData })
    }

    var leafData: LeafData {
        var dict = fieldsLeafData.dictionary!
        dict["notification"] = .string(notification)
        return .dictionary(dict)
    }
    
    func initialize(req: Request) -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }
    
    func processInput(req: Request) throws -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }
    
    func validateFields() -> Bool {
        var isValid = true
        for field in fields {
            let isFieldValid = field.validate()
            isValid = isValid && isFieldValid
        }
        return isValid
    }
    
    func validate(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(validateFields())
    }
    
    func save(req: Request) -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }
}
