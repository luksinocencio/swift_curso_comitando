import XCTest
import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {
    func test_initializer_remoteRestaurantLoader_and_validate_urlRequest(file: StaticString = #file, line: UInt = #line) throws {
        let (sut, client, anyURL) = makeSUT(file: file, line: line)
        
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
        
        assert(sut, completion: .failure(.connectivity)) {
            client.completionWithError()
        }
    }
    
    func test_load_and_returned_error_for_invalidData() throws {
        let (sut, client, _) = makeSUT()
        
        assert(sut, completion: .failure(.invalidData)) {
            client.completionWithSuccess()
        }
    }
    
    func test_load_and_returned_success_with_empty_list() {
        let (sut, client, _) = makeSUT()
        
        assert(sut, completion: .success([])) {
            client.completionWithSuccess(data: emptyData())
        }
    }
    
    func test_load_and_returned_success_with_restaurant_item_list() throws {
        let (sut, client, _) = makeSUT()
        
        let item1 = makeItem()
        let item2 = makeItem()
        
        assert(sut, completion: .success([item1.model, item2.model])) {
            let jsonItem = ["items": [item1.json, item2.json]]
            let data = try! XCTUnwrap(JSONSerialization.data(withJSONObject: jsonItem))
            client.completionWithSuccess(data: data)
        }
    }
    
    func test_load_and_returned_error_for_invalid_statusCode() throws {
        let (sut, client, _) = makeSUT()
        
        assert(sut, completion: .failure(.invalidData)) {
            let item1 = makeItem()
            let item2 = makeItem()
            let jsonItem = ["items": [item1.json, item2.json]]
            
            let data = try! XCTUnwrap(JSONSerialization.data(withJSONObject: jsonItem))
            client.completionWithSuccess(statusCode: 201, data: data)
        }
    }
    
    func test_load_not_returned_after_sut_deallocated() {
        let anyURL = URL(string: "https://comitando.com.br")!
        let client = NetworkClientSpy()
        var sut: RemoteRestaurantLoader? = RemoteRestaurantLoader(url: anyURL, networkClient: client)
        var returnedResult: RestaurantLoader.RestaurantResult?
        
        sut?.load(completion: { result in
            returnedResult = result
        })
        
        sut = nil
        client.completionWithSuccess()
        
        XCTAssertNil(returnedResult)
    }
}

extension RestaurantDomainTests {
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (RemoteRestaurantLoader, client: NetworkClientSpy, anyURL: URL) {
        let anyURL = URL(string: "https://comitando.com.br")!
        let client = NetworkClientSpy()
        let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
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
    
    private func assert(
        _ sut: RemoteRestaurantLoader,
        completion result: RestaurantLoader.RestaurantResult?,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "esperando retorno da closure")
        var returnResult: RestaurantLoader.RestaurantResult?
        
        sut.load { result in
            returnResult = result
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(returnResult, result)
    }
}
