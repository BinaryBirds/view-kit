//
//  ViewContextRepresentable.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 25..
//

/// returns a contexts for the rendered views
public protocol ViewContextRepresentable {
    /// generic context type
    associatedtype ViewContext: Encodable

    /// returns the context object
    var viewContext: ViewContext { get }
    var viewIdentifier: String { get }
}
