//
//  AdminViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

import Vapor
import Fluent

public protocol AdminViewController: ListViewController,
    CreateViewController,
    UpdateViewController,
    DeleteViewController
{
    func setupRoutes(routes: RoutesBuilder,
                     on pathComponent: PathComponent,
                     create: PathComponent,
                     delete: PathComponent)
}

public extension AdminViewController {

    func setupRoutes(routes: RoutesBuilder,
                     on pathComponent: PathComponent,
                     create: PathComponent = "new",
                     delete: PathComponent = "delete")
    {
        let base = routes.grouped(pathComponent)
        self.setupListRoute(routes: base)
        self.setupCreateRoutes(routes: base, on: create)
        self.setupUpdateRoutes(routes: base)
        self.setupDeleteRoute(routes: base, on: delete)
    }
}
