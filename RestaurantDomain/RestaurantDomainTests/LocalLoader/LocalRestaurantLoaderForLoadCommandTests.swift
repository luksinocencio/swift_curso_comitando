import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderForLoadCommandTests: XCTestCase {
    func test_load_returned_completion_error() {
        let (sut, cache) = makeSUT()
        let anyError = NSError(domain: "any error", code: -1)
        assert(sut, completion: .failure(.invalidData)) {
            cache.completionHandlerForLoad(.failure(anyError))
        }
        
        XCTAssertEqual(cache.methodsCalled, [.load])
    }
    
    func test_load_returned_completion_success_with_empty_data() {
        let (sut, cache) = makeSUT()
        
        assert(sut, completion: .success([])) {
            cache.completionHandlerForLoad(.empty)
        }
        
        XCTAssertEqual(cache.methodsCalled, [.load])
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
    
    private func assert(
        _ sut: LocalRestaurantLoader,
        completion result: (Result<[RestaurantItem], RestaurantResultError>)??,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let items = [makeItem()]
        
        var returnedResult: (Result<[RestaurantItem], RestaurantResultError>)?
        sut.load { result in
            returnedResult = result
        }
        
        action()
        
        XCTAssertEqual(returnedResult, result)
    }
}
