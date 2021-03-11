//
//  ListPageInfo.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 10. 18..
//

/// pagination metadata info
public struct ListPageInfo: TemplateDataRepresentable {

    /// current page
    public let current: Int
    /// pagination limit (items per page)
    public let limit: Int
    /// total number of pages
    public let total: Int
    
    /// public init method
    public init(current: Int, limit: Int, total: Int) {
        self.current = current
        self.limit = limit
        self.total = total
    }
    
    public var templateData: TemplateData {
        .dictionary([
            "current": .int(current),
            "limit": .int(limit),
            "total": .int(total),
        ])
    }
}
