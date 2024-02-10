@testable import HTTPServer
import XCTVapor

final class HTTPServerTests: XCTestCase {
    func testItems() async throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try await configure(app)

        try app.test(.GET, "items", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }
}
