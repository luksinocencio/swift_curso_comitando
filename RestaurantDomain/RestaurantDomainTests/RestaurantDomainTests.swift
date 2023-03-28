import XCTest
@testable import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {
    func test_initializer_remoteRestaurantLoader_and_validate_urlRequest() throws {
        let anyURL = try XCTUnwrap(URL(string: "https://comitando.com.br"))
        let client = NetworkClientSpy()
        let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.urlRequests, [anyURL])
        
    }
    
    func test_load_twice() throws {
        let anyURL = try XCTUnwrap(URL(string: "https://comitando.com.br"))
        let client = NetworkClientSpy()
        let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.urlRequests, [anyURL, anyURL])
    }
    
    func test_load_and_returned_error_for_connectivity() throws {
        let anyURL = try XCTUnwrap(URL(string: "https://comitando.com.br"))
        let client = NetworkClientSpy()
        let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)
        
        let exp = expectation(description: "esperando retorno da closure")
        var returnResult: RemoteRestaurantLoader.Error?
        
        sut.load { result in
            returnResult = result
            exp.fulfill()
        }
        
        client.completionWithError()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(returnResult, .connectivity)
    }
    
    func test_load_and_returned_error_for_invalidData() throws {
        let anyURL = try XCTUnwrap(URL(string: "https://comitando.com.br"))
        let client = NetworkClientSpy()
        let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)
        
        let exp = expectation(description: "esperando retorno da closure")
        var returnResult: RemoteRestaurantLoader.Error?
        
        sut.load { result in
            returnResult = result
            exp.fulfill()
        }
        
        client.completionWithSuccess()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(returnResult, .invalidData)
    }
}

final class NetworkClientSpy: NetworkClient {
    private(set) var urlRequests: [URL] = []
    private var completionHandler: ((NetworkState) -> Void)?
    
    func request(from url: URL, completion: @escaping (NetworkState) -> Void) {
        urlRequests.append(url)
        completionHandler = completion
    }
    
    func completionWithError() {
        completionHandler?(.error(anyError()))
    }
    
    func completionWithSuccess() {
        completionHandler?(.success)
    }
    
    func anyError() -> Error {
        return NSError(domain: "any error", code: -1)
    }
}
