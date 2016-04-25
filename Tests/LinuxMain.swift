#if os(Linux)

import XCTest
@testable import BasicAuthMiddlewareTestSuite

XCTMain([
    testCase(BasicAuthMiddlewareTests.allTests)
])

#endif
