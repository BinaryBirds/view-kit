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
    func findBy(_ id: Model.IDValue, on: Database) -> EventLoopFuture<Model>
}

public extension IdentifiableViewController {

    var idParamKey: String { "id" }
    var idPathComponent: PathComponent { .init(stringLiteral: ":\(idParamKey)") }

    func findBy(_ id: Model.IDValue, on db: Database) -> EventLoopFuture<Model> {
        Model.find(id, on: db).unwrap(or: Abort(.notFound))
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
}
