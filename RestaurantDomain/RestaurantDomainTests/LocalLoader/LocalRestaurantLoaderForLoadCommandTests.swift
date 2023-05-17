import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderForLoadCommandTests: XCTestCase {
    func test_load_returned_completion_error() {
        let (sut, cache) = makeSUT()
        var returnedResult: (Result<[RestaurantItem], RestaurantResultError>)?
        sut.load { result in
            returnedResult = result
        }
        
        let anyError = NSError(domain: "any error", code: -1)
        cache.completionHandlerForLoad(anyError)
        
        XCTAssertEqual(cache.methodsCalled, [.load])
        XCTAssertEqual(returnedResult, .failure(.invalidData))
    }
    
    func test_load_returned_completion_success_with_empty_data() {
        let (sut, cache) = makeSUT()
        var returnedResult: (Result<[RestaurantItem], RestaurantResultError>)?
        sut.load { result in
            returnedResult = result
        }
        
        cache.completionHandlerForLoad(nil)
        
        XCTAssertEqual(cache.methodsCalled, [.load])
        XCTAssertEqual(returnedResult, .success([]))
    }
}

extension LocalRestaurantLoaderForLoadCommandTests {
    private func makeSUT(currentDate: Date = Date(), file: StaticString = #file, line: UInt = #line) -> (sut: LocalRestaurantLoader, cache: CacheClientSpy) {
        let cache = CacheClientSpy()
        let sut = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })
        
        trackForMemoryLeaks(cache)
        trackForMemoryLeaks(sut)
        
        return (sut, cache)
    }
    
    private func makeItem() -> RestaurantItem {
        RestaurantItem(id: UUID(), name: "any_name", location: "any_location", distance: 5.5, ratings: 0, parasols: 0)
    }
}
