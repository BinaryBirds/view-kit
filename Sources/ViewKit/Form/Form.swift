//
//  Form.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 22..
//

import Vapor
import Fluent

/// can be used to build forms
public protocol Form: AnyObject, Encodable {

    /// the associated model
    associatedtype Model: Fluent.Model

    /// raw string identifier of the associated model
    var id: String? { get }
    
    /// init a form
    init()

    /// init a form using an incoming request
    init(req: Request) throws
    
    /// validates the form
    func validate(req: Request) -> EventLoopFuture<Bool>
    
    /// loads the form field values using the model
    func read(from: Model)
    
    /// saves the form field values into the model
    func write(to: Model)
}
