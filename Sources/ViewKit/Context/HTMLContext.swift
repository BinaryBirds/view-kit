//
//  HTMLContext.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

/// a generic HTML context 
public struct HTMLContext<T: Encodable, U: Encodable>: Encodable {
    public var head: T
    public var body: U

    public init(_ head: T, _ body: U) {
        self.head = head
        self.body = body
    }
}


