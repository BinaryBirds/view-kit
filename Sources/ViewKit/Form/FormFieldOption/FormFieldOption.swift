//
//  FormFieldStringOption.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//


/// selectable option
public struct FormFieldOption {

    public let key: String
    public let label: String
    
    public init(key: String, label: String) {
        self.key = key
        self.label = label
    }

    public var leafData: LeafData {
        .dictionary([
            "key": key,
            "label": label,
        ])
    }
}
