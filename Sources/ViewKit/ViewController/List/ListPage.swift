//
//  ListPage.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 08. 22..
//

/// a custom paged list with metadata information
public struct ListPage<T>: LeafDataRepresentable where T: LeafDataRepresentable {

    /// paged generic encodable items
    public let items: [T]

    /// additional page information
    public let info: ListPageInfo

    /// generic init method
    public init(_ items: [T], info: ListPageInfo) {
        self.items = items
        self.info = info
    }

    /// NOTE: we can only nest metadata if we init a new object...
    public func map<U>(_ transform: (T) throws -> (U)) rethrows -> ListPage<U> where U: LeafDataRepresentable {
        try .init(items.map(transform), info: info)
    }
   
    public var leafData: LeafData {
        .dictionary([
            "items": .array(items.map(\.leafData)),
            "info": info.leafData
        ])
    }
}
