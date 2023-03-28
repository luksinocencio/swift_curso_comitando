import XCTest
@testable import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {
    func test_initializer_remoteRestaurantLoader_and_validate_urlRequest() throws {
        // to avoid force unwrape
        let anyURL = try XCTUnwrap(URL(string: "https://comitando.com.br"))
        // system under test
        let sut = RemoteRestaurantLoader(url: anyURL)
        
        sut.load()
        
        XCTAssertNotNil(NetworkClient.shared.urlRequest)
    }
}
