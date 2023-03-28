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
    
    func test_load_and_returned_success_with_restaurant_item_list() throws {
        let (sut, client, _) = makeSUT()
        let exp = expectation(description: "esperando retorno da closure")
        var returnResult: RemoteRestaurantLoader.RemoteRestaurantResult?
        
        sut.load { result in
            returnResult = result
            exp.fulfill()
        }
        let (model1, json1) = makeItem()
        let (model2, json2) = makeItem()
        
        let jsonItem = ["items": [json1, json2]]
        
        let data = try XCTUnwrap(JSONSerialization.data(withJSONObject: jsonItem))
        
        client.completionWithSuccess(data: data)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(returnResult, .success([model1, model2]))
    }
    
    func test_load_and_returned_error_for_invalid_statusCode() throws {
        let (sut, client, _) = makeSUT()
        let exp = expectation(description: "esperando retorno da closure")
        var returnResult: RemoteRestaurantLoader.RemoteRestaurantResult?
        
        sut.load { result in
            returnResult = result
            exp.fulfill()
        }
        let (_, json1) = makeItem()
        let (_, json2) = makeItem()
        
        let jsonItem = ["items": [json1, json2]]
        
        let data = try XCTUnwrap(JSONSerialization.data(withJSONObject: jsonItem))
        
        client.completionWithSuccess(statusCode: 201, data: data)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(returnResult, .failure(.invalidData))
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
    
    private func makeItem(
        id: UUID = UUID(),
        name: String = "name",
        location: String = "location",
        distance: Float = 5.5,
        ratings: Int = 4,
        parasols: Int = 10
    ) -> (model: RestaurantItem, json: [String: Any]) {
        let item = RestaurantItem(
            id: id,
            name: name,
            location: location,
            distance: distance,
            ratings: ratings,
            parasols: parasols
        )
        
        let itemJson: [String: Any] = [
            "id": item.id.uuidString,
            "name": item.name,
            "location": item.location,
            "distance": item.distance,
            "ratings": item.ratings,
            "parasols": item.parasols
        ]
        
        return (item, itemJson)
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
