//
//  ViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

import Vapor
import Fluent

public protocol ViewController {
    
    associatedtype Model: Fluent.Model & ViewContextRepresentable
}
