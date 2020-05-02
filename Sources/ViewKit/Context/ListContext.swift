//
//  ListContext.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 25..
//

/// a generic list context for rendering list items
public struct ListContext<T: Encodable>: Encodable {
    /// encodable list property
    public var list: [T]
    
    public init(_ list: [T]) {
        self.list = list
    }
}
