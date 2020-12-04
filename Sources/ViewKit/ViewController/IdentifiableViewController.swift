//
//  IdentifiableViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol IdentifiableViewController: ViewController {

    /// name of the identifier key
    var idParamKey: String { get }
    
    /// path component based on the identifier key name
    var idPathComponent: PathComponent { get }
    
    /// finds and unwraps a model based on the identifier key
    func find(_: Request) throws -> EventLoopFuture<Model>
}

public extension IdentifiableViewController {

    var idParamKey: String { "id" }
    var idPathComponent: PathComponent { .init(stringLiteral: ":\(idParamKey)") }
}

public extension IdentifiableViewController where Model.IDValue == UUID {

    func find(_ req: Request) throws -> EventLoopFuture<Model> {
        guard
            let id = req.parameters.get(idParamKey),
            let uuid = UUID(uuidString: id)
        else {
            throw Abort(.badRequest)
        }
        return Model.find(uuid, on: req.db).unwrap(or: Abort(.notFound))
    }
}
