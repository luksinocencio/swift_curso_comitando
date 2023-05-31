import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderForValidateCacheCommandTests: XCTestCase {
    func test_load_delete_cache_after_error_to_load() {
        let (sut, cache) = makeSUT()
        
        sut.validateCache()
        let anyError = NSError(domain: "any error", code: -1)
        cache.completionHandlerForLoad(.failure(anyError))
        
        XCTAssertEqual(cache.methodsCalled, [.load, .delete])
    }
    
    func test_load_nonDelete_cache_after_empty_result() {
        let (sut, cache) = makeSUT()
        
        sut.validateCache()
        cache.completionHandlerForLoad(.empty)
        
        XCTAssertEqual(cache.methodsCalled, [.load])
    }
    
    
    func test_load_onDelete_cache_after_error_to_load() {
        let currentData = Date()
        let oneDayLessThanOldCacheDate = currentData.addind(days: -1).adding(seconds: 1)
        let (sut, cache) = makeSUT(currentDate: currentData)
        let items = [makeItem()]
        
        sut.validateCache()
        cache.completionHandlerForLoad(.success(items: items, timestamp: oneDayLessThanOldCacheDate))
        
        XCTAssertEqual(cache.methodsCalled, [.load])
    }
    
    func test_load_onDelete_cache_when_one_day_old_cache() {
        let currentData = Date()
        let oneDayLessThanOldCacheDate = currentData.addind(days: -1)
        let (sut, cache) = makeSUT(currentDate: currentData)
        let items = [makeItem()]
        
        sut.validateCache()
        cache.completionHandlerForLoad(.success(items: items, timestamp: oneDayLessThanOldCacheDate))
        
        XCTAssertEqual(cache.methodsCalled, [.load, .delete])
    }
}

extension LocalRestaurantLoaderForValidateCacheCommandTests {
    private func makeSUT(currentDate: Date = Date(), file: StaticString = #file, line: UInt = #line) -> (sut: LocalRestaurantLoader, cache: CacheClientSpy) {
        let cache = CacheClientSpy()
        let sut = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })
        
        trackForMemoryLeaks(cache)
        trackForMemoryLeaks(sut)
        
        return (sut, cache)
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
