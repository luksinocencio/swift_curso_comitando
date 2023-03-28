import XCTest
@testable import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {
    func test_initializer_remoteRestaurantLoader_and_validate_urlRequest() throws {
        let (sut, client, anyURL) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.urlRequests, [anyURL])
    }
    
    func test_load_twice() throws {
        let (sut, client, anyURL) = makeSUT()
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.urlRequests, [anyURL, anyURL])
    }
    
    func test_load_and_returned_error_for_connectivity() throws {
        let (sut, client, _) = makeSUT()
        let exp = expectation(description: "esperando retorno da closure")
        var returnResult: RemoteRestaurantLoader.RemoteRestaurantResult?
        
        sut.load { result in
            returnResult = result
            exp.fulfill()
        }
        
        client.completionWithError()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(returnResult, .failure(.connectivity))
    }
    
    func test_load_and_returned_error_for_invalidData() throws {
        let (sut, client, _) = makeSUT()
        let exp = expectation(description: "esperando retorno da closure")
        var returnResult: RemoteRestaurantLoader.RemoteRestaurantResult?
        
        sut.load { result in
            returnResult = result
            exp.fulfill()
        }
        
        client.completionWithSuccess()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(returnResult, .failure(.invalidData))
    }
    
    func test_load_and_returned_success_with_empty_list() {
        let (sut, client, _) = makeSUT()
        let exp = expectation(description: "esperando retorno da closure")
        var returnResult: RemoteRestaurantLoader.RemoteRestaurantResult?
        
        sut.load { result in
            returnResult = result
            exp.fulfill()
        }
        
        client.completionWithSuccess(data: emptyData())
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(returnResult, .success([]))
    }
}

extension RestaurantDomainTests {
    private func makeSUT()  -> (RemoteRestaurantLoader, client: NetworkClientSpy, anyURL: URL) {
        let anyURL = URL(string: "https://comitando.com.br")!
        let client = NetworkClientSpy()
        let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)
        
        return (sut, client, anyURL)
    }
    
    private func emptyData() -> Data {
        return Data("{\"items\": []}".utf8)
    }
}

final class NetworkClientSpy: NetworkClient {
    private(set) var urlRequests: [URL] = []
    private var completionHandler: ((NetworkResult) -> Void)?
    
    func request(from url: URL, completion: @escaping (NetworkResult) -> Void) {
        urlRequests.append(url)
        completionHandler = completion
    }
    
    func completionWithError() {
        completionHandler?(.failure(anyError()))
    }
    
    func completionWithSuccess(statusCode: Int = 200, data: Data = Data()) {
        let response = HTTPURLResponse(url: urlRequests[0], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        completionHandler?(.success(( data, response )))
    }
    
    func anyError() -> Error {
        return NSError(domain: "any error", code: -1)
    }
}
