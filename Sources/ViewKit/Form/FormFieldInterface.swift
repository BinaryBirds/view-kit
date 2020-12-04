//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 12. 04..
//

public protocol FormFieldInterface: LeafDataRepresentable {

    /// form field key for the leaf data representation
    var key: String { get }

    /// validates a given form field
    func validate() -> Bool
}
