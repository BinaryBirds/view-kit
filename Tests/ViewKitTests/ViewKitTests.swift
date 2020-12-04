import XCTest
import ViewKit

final class ViewKitTests: XCTestCase {
    
    func testExample() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        let controller = ExampleController()
        let req = Request(application: app, method: .GET, url: "", on: app.eventLoopGroup.next())
        _ = try controller.getView(req: req).wait()
        XCTAssertTrue(true)
    }

    func testModelFormLeafDataIdentifier() throws {
        let uuid = UUID()
        let form = ExampleEditForm()
        form.modelId = uuid
        let data = form.leafData
        XCTAssertEqual(data.dictionary?["id"], uuid.leafData)
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
