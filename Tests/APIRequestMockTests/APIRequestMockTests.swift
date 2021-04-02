import XCTest
@testable import APIRequestMock

final class APIRequestMockTests: XCTestCase {
    func testLoadingMock() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let mockedResponse = """
        [
            {
                "enabled": true,
                "uri": ["https://sampleurl.io/api/v1/items"],
                "headers": {"api_token": "123"},
                "comment": "Sample mocked response",
                "value": [
                    { "value": 1 },
                    { "value": 2 },
                    { "value": 3 },
                ]
            }
        ]
        """
        let items = APIRequestMock.loadItem(from: mockedResponse.data(using: .utf8)!)
        XCTAssertEqual(items?.count, 1)
        XCTAssertEqual(items?.first?.isEnabled, true)
        XCTAssertEqual(items?.first?.uri, ["https://sampleurl.io/api/v1/items"])
        XCTAssertEqual(items?.first?.comment, "Sample mocked response")
    }
    
    func testRegisteringMock() {
        let configuration = URLSessionConfiguration.default
        APIRequestMock.register(resourceNames: ["responses.json"], in: configuration)
        let session = URLSession(configuration: configuration)
    }

    static var allTests = [
        ("testLoadingMock", testLoadingMock),
    ]
}
