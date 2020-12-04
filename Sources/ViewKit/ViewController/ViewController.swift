//
//  ViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//


public protocol ViewController {
    
    associatedtype Model: Fluent.Model & LeafDataRepresentable

    func render(req: Request, template: String, context: LeafRenderer.Context) -> EventLoopFuture<View>
}

public extension ViewController {

    func render(req: Request, template: String, context: LeafRenderer.Context) -> EventLoopFuture<View> {
        req.leaf.render(template: template, context: context)
    }
}
