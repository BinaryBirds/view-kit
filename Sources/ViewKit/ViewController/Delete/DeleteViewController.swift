//
//  DeleteViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 04..
//

public protocol DeleteViewController: IdentifiableViewController {
 
    /// the view used to render the delete form
    var deleteView: String { get }

    /// check if there is access to delete the object, if the future the server will respond with a forbidden status
    func accessDelete(req: Request) -> EventLoopFuture<Bool>
    
    /// this will be called before the model is deleted
    func beforeDelete(req: Request, model: Model) -> EventLoopFuture<Model>
    
    /// deletes a model from the database
    func delete(req: Request) throws -> EventLoopFuture<Response>
    
    /// this method will be called after a succesful deletion
    func afterDelete(req: Request, model: Model) -> EventLoopFuture<Model>
    
    /// returns a response after completing the delete request
    func deleteResponse(req: Request, model: Model) -> EventLoopFuture<Response>
    
    /// setup the get and post routes for the delete controller
    func setupDeleteRoutes(on: RoutesBuilder, as: PathComponent)
}
