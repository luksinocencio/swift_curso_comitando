import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderForLoadCommandTests: XCTestCase {
    func test_load_returned_completion_error() {
        let (sut, cache) = makeSUT()
        let anyError = NSError(domain: "any error", code: -1)
        assert(sut, completion: .failure(.invalidData)) {
            cache.completionHandlerForLoad(.failure(anyError))
        }
    }
    
    func test_load_returned_completion_success_with_empty_data() {
        let (sut, cache) = makeSUT()
        
        assert(sut, completion: .success([])) {
            cache.completionHandlerForLoad(.empty)
        }
        
        XCTAssertEqual(cache.methodsCalled, [.load])
    }
    
    func test_load_returned_data_with_one_day_less_than_old_cache() {
        let currentDate = Date()
        let oneDayLessThanOlcCacheDate = currentDate.addind(days: -1).adding(seconds: 1)
        
        let (sut, cache) = makeSUT(currentDate: currentDate)
        let items = [makeItem()]
        
        assert(sut, completion: .success(items)) {
            cache.completionHandlerForLoad(.success(items: items, timestamp: oneDayLessThanOlcCacheDate))
        }
    }
    
    func test_load_returned_data_with_one_day_old_cache() {
        let currentDate = Date()
        let oneDayOldCacheDate = currentDate.addind(days: -1)
        
        let (sut, cache) = makeSUT(currentDate: currentDate)
        let items = [makeItem()]
        
        assert(sut, completion: .success([])) {
            cache.completionHandlerForLoad(.success(items: items, timestamp: oneDayOldCacheDate))
        }
    }
    
    func test_load_delete_cache_after_error_to_load() {
        let (sut, cache) = makeSUT()
        
        sut.load { _ in }
        let anyError = NSError(domain: "any error", code: -1)
        cache.completionHandlerForLoad(.failure(anyError))
        
        XCTAssertEqual(cache.methodsCalled, [.load, .delete])
    }
    
    func test_load_nonDelete_cache_after_empty_result() {
        let (sut, cache) = makeSUT()
        
        sut.load { _ in }
        
        cache.completionHandlerForLoad(.empty)
        
        XCTAssertEqual(cache.methodsCalled, [.load])
    }
    
    
    func test_load_onDelete_cache_after_error_to_load() {
        let currentData = Date()
        let oneDayLessThanOldCacheDate = currentData.addind(days: -1).adding(seconds: 1)
        let (sut, cache) = makeSUT(currentDate: currentData)
        let items = [makeItem()]
        
        sut.load { _ in }
        cache.completionHandlerForLoad(.success(items: items, timestamp: oneDayLessThanOldCacheDate))
        
        XCTAssertEqual(cache.methodsCalled, [.load])
    }
    
    func test_load_onDelete_cache_when_one_day_old_cache() {
        let currentData = Date()
        let oneDayLessThanOldCacheDate = currentData.addind(days: -1)
        let (sut, cache) = makeSUT(currentDate: currentData)
        let items = [makeItem()]
        
        sut.load { _ in }
        cache.completionHandlerForLoad(.success(items: items, timestamp: oneDayLessThanOldCacheDate))
        
        XCTAssertEqual(cache.methodsCalled, [.load, .delete])
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

private extension Date {
    func addind(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
