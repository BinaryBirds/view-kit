//
//  GetViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 04..
//

public protocol GetViewController: IdentifiableViewController {

    /// the name of the get view template
    var getView: String { get }

    /// check if there is access to get tehe object, if the future the server will respond with a forbidden status
    func accessGet(req: Request) -> EventLoopFuture<Bool>
    
    /// builds the query in order to get the object in the admin interface
    func beforeGet(req: Request, model: Model) -> EventLoopFuture<Model>
    
    /// renders the get view
    func get(req: Request) throws -> EventLoopFuture<Response>

    /// returns a response after the get request
    func getResponse(req: Request, model: Model) -> EventLoopFuture<Response>

    /// setup get related route
    func setupGetRoute(on: RoutesBuilder)
}
