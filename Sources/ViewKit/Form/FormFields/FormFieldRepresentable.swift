//
//  FormFieldRepresentable.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 05..
//

public protocol FormFieldRepresentable: AnyObject, LeafDataRepresentable {

    var key: String { get set }

    /// name of the form field
    var name: String? { get set }

    /// error message
    var error: String? { get set }

    /// validates the form field
    func validate() -> Bool

    /// process input using the request
    func process(req: Request)
}
