//
//  ViewController.swift
//  ViewKit
//
//  Created by Tibor Bodecs on 2020. 04. 26..
//

public protocol ViewController {
    
    associatedtype Model: Fluent.Model & LeafDataRepresentable
}
