import XCTest
import RestaurantDomain
@testable import SunnyDay

final class RestaurantLoaderCacheDecoratorTests: XCTestCase {
    func test_decoratee_load_should_be_completion_success() {
        let items = [makeItem()]
        let result: RestaurantLoader.RestaurantResult = .success(items)
        let (sut, _) = makeSUT(result: result)
        
        assert(sut, completion: result)
    }
    
    func test_decoratee_load_should_be_completion_error() {
        let result: RestaurantLoader.RestaurantResult = .failure(.connectivity)
        let (sut, cache) = makeSUT(result: result)
        
        sut.load { _ in }
        XCTAssertTrue(cache.methodsCalled.isEmpty)
    }
    
    func test_cache_insert_after_load_returned_success() {
        let items = [makeItem()]
        let result: RestaurantLoader.RestaurantResult = .success(items)
        let (sut, cache) = makeSUT(result: result)
        
        assert(sut, completion: result)
        XCTAssertEqual(cache.methodsCalled, [.save(items)])
    }
    
    func test_cache_no_insert_load_returned_failure() {
        let result: RestaurantLoader.RestaurantResult = .failure(.connectivity)
        let (sut, cache) = makeSUT(result: result)
        
        sut.load { _ in }
        XCTAssertTrue(cache.methodsCalled.isEmpty)
    }
}

extension RestaurantLoaderCacheDecoratorTests {
    private func makeSUT(
        result: RestaurantLoader.RestaurantResult,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: RestaurantLoaderCacheDecorator, cache: LocalRestaurantLoaderInsertSpy) {
        let cache = LocalRestaurantLoaderInsertSpy()
        let service = RestaurantLoaderSpy(result: result)
        let sut = RestaurantLoaderCacheDecorator(decoratee: service, cache: cache)
        trackForMemoryLeaks(service)
        trackForMemoryLeaks(sut)
        
        return (sut, cache)
    }
    
    private func assert(
        _ sut: RestaurantLoader,
        completion result: RestaurantLoader.RestaurantResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "esperando bloco ser completado")
        sut.load { returnedResult in
            switch (result, returnedResult) {
                case let (.success(resultItems), .success(returnItems)):
                    XCTAssertEqual(resultItems, returnItems, file: file, line: line)
                case (.failure, .failure):
                    break
                default:
                    XCTFail("Esperado \(returnedResult), porem retornou \(returnedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}


final class LocalRestaurantLoaderInsertSpy: LocalRestaurantLoaderInsert {
    
    enum Methods: Equatable {
        case save([RestaurantItem])
    }
    
    private(set) var methodsCalled = [Methods]()
    private var completionHandler: ((Error?) -> Void)?
    
    func save(_ items: [RestaurantDomain.RestaurantItem], completion: @escaping (Error?) -> Void) {
        methodsCalled.append(.save(items))
        completionHandler = completion
    }
    
    func completionResult(_ error: Error?) {
        completionHandler?(error)
    }
}
