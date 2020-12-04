//
//  ListSort.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 10. 19..
//

public enum ListSort: String, CaseIterable {
    case asc
    case desc
    
    public var direction: DatabaseQuery.Sort.Direction {
        switch self {
        case .asc:
            return .ascending
        case .desc:
            return .descending
        }
    }
}
