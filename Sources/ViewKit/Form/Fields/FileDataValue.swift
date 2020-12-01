//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 12. 01..
//

/// represents a file data value
public struct FileDataValue: LeafDataRepresentable {
    /// name of the uploaded file
    public let name: String
    
    /// data value of the uploaded file
    public let data: Data
    
    /// public init
    public init(name: String, data: Data) {
        self.name = name
        self.data = data
    }

    public var leafData: LeafData {
        .dictionary([
            "name": .string(name),
            "data": .data(data),
        ])
    }
}
