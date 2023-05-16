import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderTests: XCTestCase {
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

extension LocalRestaurantLoaderTests {
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

final class CacheClientSpy: CacheClient {
    enum Methods: Equatable {
        case delete
        case save(items: [RestaurantItem], timestamp: Date)
    }
    
    private (set) var methodsCalled = [Methods]()
    private var completionHanlderDelete: ((Error?) -> Void)?
    private var completionHandlerInsert: ((Error?) -> Void)?
    
    func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping CacheClient.SaveResult) {
        methodsCalled.append(.save(items: items, timestamp: timestamp))
        completionHandlerInsert = completion
    }
    
    func delete(completion: @escaping CacheClient.DeleteResult) {
        methodsCalled.append(.delete)
        completionHanlderDelete = completion
    }
    
    func completionHandlerForDelete(_ error: Error?) {
        completionHanlderDelete?(error)
    }
    
    func completionHandlerForInsert(_ error: Error?) {
        completionHanlderDelete?(error)
    }
}
