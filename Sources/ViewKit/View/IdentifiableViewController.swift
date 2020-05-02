//
//  IdentifiableViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol IdentifiableViewController: ViewController {
    
    var idParamKey: String { get }
    var idPathComponent: PathComponent { get }
    func find(_ req: Request) throws -> EventLoopFuture<Model>
}

public extension IdentifiableViewController {
    var idParamKey: String { "id" }
    var idPathComponent: PathComponent { .init(stringLiteral: ":\(self.idParamKey)") }
}

public extension IdentifiableViewController where Model.IDValue == UUID {

    func find(_ req: Request) throws -> EventLoopFuture<Model> {
        guard
            let id = req.parameters.get(self.idParamKey),
            let uuid = UUID(uuidString: id)
        else {
            throw Abort(.badRequest)
        }

        return Model.find(uuid, on: req.db).unwrap(or: Abort(.notFound))
    }
}
