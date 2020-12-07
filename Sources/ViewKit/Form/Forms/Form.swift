//
//  Form.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 22..
//

public protocol Form: AnyObject, LeafDataRepresentable {

    /// form fields
    var fields: [AbstractFormField] { get }
    /// leaf data representation of the form fields
    var fieldsLeafData: LeafData { get }
    
    /// generic notification
    var notification: String? { get set }

    init()

    /// initialize form values asynchronously
    func initialize(req: Request) -> EventLoopFuture<Void>
    /// process input value from an incoming request
    func processInput(req: Request) throws -> EventLoopFuture<Void>

    /// validate form fields
    func validateFields() -> Bool
    /// validate after field validation happened
    func validateAfterFields(req: Request) -> EventLoopFuture<Bool>
    /// validate the entire form
    func validate(req: Request) -> EventLoopFuture<Bool>

    func save(req: Request) -> EventLoopFuture<Void>
}

public extension Form {
    
    var fields: [AbstractFormField] { [] }

    var fieldsLeafData: LeafData {
        .dictionary(fields.reduce(into: [String: LeafData]()) { $0[$1.key] = $1.leafData })
    }

    var leafData: LeafData {
        .dictionary([
            "fields": fieldsLeafData,
            "notification": .string(notification)
        ])
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

    func validateAfterFields(req: Request) -> EventLoopFuture<Bool> {
        req.eventLoop.future(true)
    }

    func validate(req: Request) -> EventLoopFuture<Bool> {
        guard validateFields() else {
            return req.eventLoop.future(false)
        }
        return validateAfterFields(req: req)
    }
    
    func save(req: Request) -> EventLoopFuture<Void> {
        req.eventLoop.future()
    }
}
