//
//  AdminViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol AdminViewController:
    ListViewController,
    GetViewController,
    CreateViewController,
    UpdateViewController,
    DeleteViewController
{
    func setupRoutes(on: RoutesBuilder, as: PathComponent, createPath: PathComponent, updatePath: PathComponent, deletePath: PathComponent)
}

/*
 Routes & controller methods:
 ----------------------------------------
 GET /[model]/              listView
 GET /[model]/:id           getView
 GET /[model]/create        createView
    + POST                  create
 GET /[model]/:id/update    updateView
    + POST                  update
 GET /[model]/:id/delete    deleteView
    + POST                  delete
 */
public extension AdminViewController {

    func setupRoutes(on builder: RoutesBuilder,
                     as pathComponent: PathComponent,
                     createPath: PathComponent = "create",
                     updatePath: PathComponent = "update",
                     deletePath: PathComponent = "delete")
    {
        let base = builder.grouped(pathComponent)
        setupListRoute(on: base)
        setupGetRoute(on: base)
        setupCreateRoutes(on: base, as: createPath)
        setupUpdateRoutes(on: base, as: updatePath)
        setupDeleteRoutes(on: base, as: deletePath)
    }
}

