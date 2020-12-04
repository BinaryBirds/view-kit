//
//  CreateViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 12. 04..
//

public protocol CreateViewController: ViewController {

    associatedtype CreateForm: ModelFormInterface

    /// the name of the edit view template
    var createView: String { get }

    /// used after form validation when we have an invalid form
    func beforeInvalidCreateFormRender(req: Request, form: CreateForm) -> EventLoopFuture<CreateForm>
    
    /// this is called before the form rendering happens (used both in createView and updateView)
    func beforeCreateFormRender(req: Request, form: CreateForm) -> EventLoopFuture<Void>
    
    /// renders the form using the given template
    func renderCreateForm(req: Request, form: CreateForm) -> EventLoopFuture<View>

    /// check if there is access to create the object, if the future the server will respond with a forbidden status
    func accessCreate(req: Request) -> EventLoopFuture<Bool>

    /// this is the main view for the create controller
    func createView(req: Request) throws -> EventLoopFuture<View>
    
    /// this will be called before the model is saved to the database during the create event
    func beforeCreate(req: Request, model: Model, form: CreateForm) -> EventLoopFuture<Model>
    
    /// create handler for the form submission
    func create(req: Request) throws -> EventLoopFuture<Response>
    
    /// runs after the model has been created
    func afterCreate(req: Request, form: CreateForm, model: Model) -> EventLoopFuture<Response>

    /// setup the get and post create routes using the given builder
    func setupCreateRoutes(on: RoutesBuilder, as: PathComponent)
}

