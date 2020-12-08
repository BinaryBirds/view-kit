//
//  FileValue.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 01..
//

import Foundation

public extension File {

    var byteBuffer: ByteBuffer { data }

    var dataValue: Data? { byteBuffer.getData(at: 0, length: byteBuffer.readableBytes) }
}

/// represents a file data value
public final class FileValue: LeafDataRepresentable {

    public struct TemporaryFile: LeafDataRepresentable {
        public let key: String
        public let name: String
        
        public init(key: String, name: String) {
            self.key = key
            self.name = name
        }

        public var leafData: LeafData {
            .dictionary([
                "key": key,
                "name": name,
            ])
        }
    }

    public var file: File?
    public var originalKey: String?
    public var delete: Bool
    public var temporaryFile: TemporaryFile?

    public init(file: File? = nil, originalKey: String? = nil, delete: Bool = false, temporaryFile: TemporaryFile? = nil) {
        self.file = file
        self.originalKey = originalKey
        self.delete = delete
        self.temporaryFile = temporaryFile
    }

    public var leafData: LeafData {
        .dictionary([
            "key": .string(temporaryFile?.key ?? originalKey),
            "originalKey": .string(originalKey),
            "temporaryFile": temporaryFile.leafData,
            "delete": .bool(delete),
        ])
    }
}
