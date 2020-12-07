//
//  ViewKitTests.swift
//  ViewKitTests
//
//  Created by Tibor Bodecs on 2020. 04. 27..
//

import XCTest
import ViewKit

final class ViewKitTests: XCTestCase {
    
    func testModelFormLeafDataIdentifier() throws {
        let uuid = UUID()
        let form = ExampleEditForm()
        form.modelId = uuid
        let data = form.leafData
        XCTAssertEqual(data.dictionary?["modelId"], uuid.leafData)
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
