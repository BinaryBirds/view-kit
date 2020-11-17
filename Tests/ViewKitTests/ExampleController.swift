//
//  File.swift
//  
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import Vapor
import Fluent
@testable import ViewKit

final class ExampleController: AdminViewController {
    
    var listView: String = ""
    var editView: String = ""
    var deleteView: String = ""
    
    typealias Model = ExampleModel
    typealias EditForm = ExampleEditForm
}
