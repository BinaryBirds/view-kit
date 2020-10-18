//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import Vapor

struct TestRenderer: ViewRenderer {
    let eventLoopGroup: EventLoopGroup
    
    init(eventLoopGroup: EventLoopGroup) {
        self.eventLoopGroup = eventLoopGroup
    }
    
    func `for`(_ request: Request) -> ViewRenderer {
        TestRenderer(eventLoopGroup: request.eventLoop)
    }
    
    func render<E>(_ name: String, _ context: E) -> EventLoopFuture<View> where E : Encodable {
        let eventLoop = eventLoopGroup.next()

        var headers = HTTPHeaders()
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        let encoder = try! ContentConfiguration.global.requireEncoder(for: .json)
        try! encoder.encode(context, to: &buffer, headers: &headers)
        //buffer.writeString(name)
        let view = View(data: buffer)
        return eventLoop.future(view)
    }
}
