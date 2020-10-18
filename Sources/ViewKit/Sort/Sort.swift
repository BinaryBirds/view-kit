//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 10. 19..
//

public enum Sort: String, CaseIterable {
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
