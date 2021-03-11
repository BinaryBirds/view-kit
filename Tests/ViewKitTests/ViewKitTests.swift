//
//  ViewKitTests.swift
//  ViewKitTests
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import XCTest
import ViewKit

final class ViewKitTests: XCTestCase {
    
    func testModelFormTemplateDataIdentifier() throws {
        let uuid = UUID()
        let form = ExampleEditForm()
        form.modelId = uuid
        let data = form.templateData
        XCTAssertEqual(data.dictionary?["modelId"], uuid.templateData)
    }
    
    func testFormValidation() throws {
        let form = ExampleEditForm()
        XCTAssertFalse(form.validateFields())
        XCTAssertEqual(form.foo.error, "Foo is required")
        XCTAssertEqual(form.bar.error, "Bar should be greater than 300")
        form.foo.value = "sample"
        form.bar.value = 1500
        XCTAssertFalse(form.validateFields())
        XCTAssertEqual(form.foo.error, nil)
        XCTAssertEqual(form.bar.error, "Bar should be less than 900")
    }
}
