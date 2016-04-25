import XCTest
@testable import BasicAuthMiddleware

class BasicAuthMiddlewareTests: XCTestCase {
    func testReality() {
        XCTAssert(2 + 2 == 4, "Something is severely wrong here.")
    }
}

extension BasicAuthMiddlewareTests {
    static var allTests : [(String, BasicAuthMiddlewareTests -> () throws -> Void)] {
        return [
           ("testReality", testReality),
        ]
    }
}
