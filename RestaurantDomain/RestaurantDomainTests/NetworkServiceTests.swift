import XCTest
@testable import RestaurantDomain

final class NetworkServiceTests: XCTestCase {
    func test_request_and_create_dataTask_with_url() {
        let url = URL(string: "https://comitando.com.br")!
        let session = URLSessionSpy()
        let sut = NetworkService(session: session)
        
        sut.request(from: url) { _ in }
        XCTAssertNotNil(session.urlRequest)
    }
}

final class URLSessionSpy: URLSession {
    private(set) var urlRequest: URL?
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        urlRequest = url
        return URLSessionDataTask()
    }
}
