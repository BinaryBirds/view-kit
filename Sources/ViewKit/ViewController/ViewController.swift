//
//  ViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//


public protocol ViewController {
    
    associatedtype Model: Fluent.Model & TemplateDataRepresentable

    func render(req: Request, template: String, context: Renderer.Context) -> EventLoopFuture<View>
}

public extension ViewController {

    func render(req: Request, template: String, context: Renderer.Context) -> EventLoopFuture<View> {
        req.tau.render(template: template, context: context)
    }
}
