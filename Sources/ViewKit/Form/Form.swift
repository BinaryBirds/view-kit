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

    func validate(req: Request) -> EventLoopFuture<Bool>
}


