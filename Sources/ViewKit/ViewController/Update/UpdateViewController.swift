//
//  UpdateViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol UpdateViewController: IdentifiableViewController {
    
    associatedtype UpdateForm: ModelForm

    /// the name of the update view template
    var updateView: String { get }

    /// this is called after form validation when the form is invalid
    func beforeInvalidUpdateFormRender(req: Request, form: UpdateForm) -> EventLoopFuture<UpdateForm>
    
    /// this is called before the form rendering happens (used both in createView and updateView)
    func beforeUpdateFormRender(req: Request, form: UpdateForm) -> EventLoopFuture<Void>

    /// renders the form using the given template
    func renderUpdateForm(req: Request, form: UpdateForm) -> EventLoopFuture<View>
    
    /// check if there is access to update the object, if the future the server will respond with a forbidden status
    func accessUpdate(req: Request) -> EventLoopFuture<Bool>
    
    /// renders the update form filled with the entity
    func updateView(req: Request) throws -> EventLoopFuture<View>
    
    /// this will be called before the model is updated
    func beforeUpdate(req: Request, model: Model, form: UpdateForm) -> EventLoopFuture<Model>
    
    /// update handler for the form submission
    func update(req: Request) throws -> EventLoopFuture<Response>
    
    /// runs after the model was updated
    func afterUpdate(req: Request, form: UpdateForm, model: Model) -> EventLoopFuture<Response>
    
    /// setup update routes using the route builder
    func setupUpdateRoutes(on: RoutesBuilder)
}
