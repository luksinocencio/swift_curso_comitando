import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderForSaveTests: XCTestCase {
    func test_save_deletes_olds_cache() {
        let (sut, cache) = makeSUT()
        let items = [makeItem()]
        
        sut.save(items) { _ in }

        XCTAssertEqual(cache.methodsCalled, [.delete])
    }
    
    func test_save_insert_new_data_on_cache() {
        let currentDate: Date = Date()
        let (sut, cache) = makeSUT(currentDate: currentDate)
        let items = [makeItem()]
    
        sut.save(items) { _ in }
        cache.completionHandlerForDelete(nil)
        
        XCTAssertEqual(cache.methodsCalled, [.delete, .save(items: items, timestamp: currentDate)])
    }
    
    func test_save_fails_after_delete_old_cache() {
        let (sut, cache) = makeSUT()
        
        let anyError = NSError(domain: "any error", code: -1)
        assert(sut, completion: anyError) {
            cache.completionHandlerForDelete(anyError)
        }
    }
    
    func test_save_fails_after_insert_new_data_cache() {
        let (sut, cache) = makeSUT()
        
        let anyError = NSError(domain: "any error", code: -1)
        assert(sut, completion: anyError) {
            cache.completionHandlerForDelete(nil)
            cache.completionHandlerForInsert(anyError)
        }
    }
    
    func test_save_success_after_insert_new_data_cache() {
        let (sut, cache) = makeSUT()
        
        assert(sut, completion: nil) {
            cache.completionHandlerForDelete(nil)
            cache.completionHandlerForInsert(nil)
        }
    }
    
    func test_save_non_insert_after_sut_deallocated() {
        let cache = CacheClientSpy()
        let currentDate: Date = Date()
        var sut: LocalRestaurantLoader? = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })
        let items = [makeItem()]
        
        var returnedError: Error?
        sut?.save(items, completion: { error in
            returnedError = error
        })
        sut = nil
        
        cache.completionHandlerForDelete(nil)
        XCTAssertNil(returnedError)
    }
    
    func test_save_non_completion_after_sut_deallocated() {
        let cache = CacheClientSpy()
        let currentDate: Date = Date()
        var sut: LocalRestaurantLoader? = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })
        let items = [makeItem()]
        
        var returnedError: Error?
        sut?.save(items, completion: { error in
            returnedError = error
        })
        
        cache.completionHandlerForDelete(nil)
        sut = nil
        cache.completionHandlerForInsert(nil)
        
        XCTAssertNil(returnedError)
    }
}

extension LocalRestaurantLoaderForSaveTests {
    private func makeSUT(currentDate: Date = Date(), file: StaticString = #file, line: UInt = #line) -> (sut: LocalRestaurantLoader, cache: CacheClientSpy) {
        let cache = CacheClientSpy()
        let sut = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })
        
        trackForMemoryLeaks(cache)
        trackForMemoryLeaks(sut)
        
        return (sut, cache)
    }
    
    private func assert(
        _ sut: LocalRestaurantLoader,
        completion error: NSError?,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let items = [makeItem()]
        var returnedError: Error?
       
        sut.save(items) { error in
            returnedError = error
        }
        
        action()
        
        XCTAssertEqual(returnedError as? NSError, error)
    }
}
