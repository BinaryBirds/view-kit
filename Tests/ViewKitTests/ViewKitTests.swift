import Vapor
import Fluent
import XCTVapor
import XCTFluent

final class ViewKitTests: XCTestCase {

    static var allTests = [
        ("testExample", testExample),
    ]
    
    func testExample() throws {
        let app = Application(.testing)
        defer { app.shutdown() }

        let db = CallbackTestDatabase { query -> [DatabaseOutput] in
            XCTAssertEqual(query.schema, ExampleModel.schema)

            let rows = (0..<10).map { TestOutput([
                "id": UUID(),
                "foo": "Foo #\($0)",
                "bar": $0,
            ])}
            
            let result: [TestOutput] = rows

            switch query.action {
            case .create, .update:
                return [result[0]]
            default:
                return result
            }
        }

        app.databases.use(db.configuration, as: .test)
        app.views.use { app  in TestRenderer(eventLoopGroup: app.eventLoopGroup) }

        ExampleController().setupRoutes(routes: app.routes, on: "examples")

        try app.test(.GET, "/examples") { res in
            XCTAssertEqual(res.status, .ok)
            struct TestResult: Codable {
                struct Result: Codable {
                    var id: UUID
                    var foo: String
                    var bar: Int?
                }
                var list: [Result]
            }

            let decoder = try! ContentConfiguration.global.requireDecoder(for: .json)
            let content = try! decoder.decode(TestResult.self, from: res.body, headers: res.headers)
            XCTAssertEqual(content.list.count, 10)
        }
    }
}
