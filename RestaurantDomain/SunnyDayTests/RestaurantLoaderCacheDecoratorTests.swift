import XCTest
import RestaurantDomain
@testable import SunnyDay

final class RestaurantLoaderCacheDecoratorTests: XCTestCase {
    func test_decoratee_load_should_be_completion_success() {
        let items = [makeItem()]
        let cache = LocalRestaurantLoaderInsertSpy()
        let result: RestaurantLoader.RestaurantResult = .success(items)
        let sut = makeSUT(result: result, cache: cache)
        
        assert(sut, completion: result)
        XCTAssertEqual(cache.methodsCalled, [.save(items)])
    }
    
    func test_decoratee_load_should_be_completion_error() {
        let result: RestaurantLoader.RestaurantResult = .failure(.connectivity)
        let cache = LocalRestaurantLoaderInsertSpy()
        let sut = makeSUT(result: result, cache: cache)
        
        assert(sut, completion: result)
        XCTAssertTrue(cache.methodsCalled.isEmpty)
    }
}

extension RestaurantLoaderCacheDecoratorTests {
    private func makeSUT(
        result: RestaurantLoader.RestaurantResult,
        cache: LocalRestaurantLoaderInsertSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> RestaurantLoaderCacheDecorator {
        let service = RestaurantLoaderSpy(result: result)
        let sut = RestaurantLoaderCacheDecorator(decoratee: service, cache: cache)
        trackForMemoryLeaks(service)
        trackForMemoryLeaks(sut)
        
        return sut
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
