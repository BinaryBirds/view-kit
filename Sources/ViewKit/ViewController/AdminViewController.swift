//
//  AdminViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol AdminViewController: ListViewController,
    CreateViewController,
    UpdateViewController,
    DeleteViewController
{
    func setupRoutes(on: RoutesBuilder, as: PathComponent, createPath: PathComponent, deletePath: PathComponent)
}

public extension AdminViewController {

    func setupRoutes(on builder: RoutesBuilder,
                     as pathComponent: PathComponent,
                     createPath: PathComponent = "new",
                     deletePath: PathComponent = "delete")
    {
        let base = builder.grouped(pathComponent)
        setupListRoute(on: base)
        setupCreateRoutes(on: base, as: createPath)
        setupUpdateRoutes(on: base)
        setupDeleteRoutes(on: base, as: deletePath)
    }
}
