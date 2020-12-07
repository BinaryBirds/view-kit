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
    
    func identifier(_ req: Request) throws -> Model.IDValue
    
    /// find a model by identifier if not found return with a notFound error
    func find(id: Model.IDValue, req: Request) -> EventLoopFuture<Model>
    
    /// finds and unwraps a model based on the identifier key
    func find(_: Request) throws -> EventLoopFuture<Model>
}

public extension IdentifiableViewController {

    var idParamKey: String { "id" }
    var idPathComponent: PathComponent { .init(stringLiteral: ":\(idParamKey)") }

    func find(id: Model.IDValue, req: Request) -> EventLoopFuture<Model> {
        Model.find(id, on: req.db).unwrap(or: Abort(.notFound))
    }
}

public extension IdentifiableViewController where Model.IDValue == UUID {

    func identifier(_ req: Request) throws -> Model.IDValue {
        guard
            let id = req.parameters.get(idParamKey),
            let uuid = UUID(uuidString: id)
        else {
            throw Abort(.badRequest)
        }
        return uuid
    }

    func find(_ req: Request) throws -> EventLoopFuture<Model> {
        let id = try identifier(req)
        return find(id: id, req: req)
    }
}
