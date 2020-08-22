//
//  PageContext.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 08. 22..
//

/// a custom page context with metadata information
public struct PageContext<T>: Encodable where T: Encodable {

    /// pagination metadata info
    public struct Metadata: Encodable {

        /// current page
        public let page: Int
        /// pagination limit (items per page)
        public let limit: Int
        /// total number of pages
        public let total: Int
        
        /// public init method
        public init(page: Int, limit: Int, total: Int) {
            self.page = page
            self.limit = limit
            self.total = total
        }
    }

    /// paged generic encodable items
    public let items: [T]

    /// additional page information
    public let metadata: Metadata

    /// generic init method
    public init(items: [T], metadata: Metadata) {
        self.items = items
        self.metadata = metadata
    }

    /// NOTE: we can only nest metadata if we init a new object...
    public func map<U>(_ transform: (T) throws -> (U)) rethrows -> PageContext<U> where U: Encodable {
        try .init(items: self.items.map(transform), metadata: .init(page: self.metadata.page, limit: self.metadata.limit, total: self.metadata.total))
    }
}

