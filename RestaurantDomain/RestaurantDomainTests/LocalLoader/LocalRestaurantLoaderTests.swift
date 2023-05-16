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
        let (sut, cache) = makeSUT()
        let items = [makeItem()]
    
        sut.save(items) { _ in }
        cache.completionHandlerForDelete(nil)
        
        XCTAssertEqual(cache.methodsCalled, [.delete, .save(items: items, timestamp: currentDate)])
    }
    
    func test_save_fails_after_delete_old_cache() {
        let (sut, cache) = makeSUT()
        let items = [makeItem()]
        
        var returnedError: Error?
        sut.save(items) { error in
            returnedError = error
        }
        
        let anyError = NSError(domain: "any error", code: -1)
        cache.completionHandlerForDelete(anyError)
        
        XCTAssertNotNil(returnedError)
        XCTAssertEqual(returnedError as? NSError, anyError)
    }
    
    func test_save_fails_after_insert_new_data_cache() {
        let (sut, cache) = makeSUT()
        let items = [makeItem()]
        
        var returnedError: Error?
        sut.save(items) { error in
            returnedError = error
        }
        
        let anyError = NSError(domain: "any error", code: -1)
        cache.completionHandlerForDelete(nil)
        cache.completionHandlerForInsert(anyError)
        
        XCTAssertEqual(returnedError as? NSError, anyError)
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
}

final class CacheClientSpy: CacheClient {
    enum Methods: Equatable {
        case delete
        case save(items: [RestaurantItem], timestamp: Date)
    }
    
    private (set) var methodsCalled = [Methods]()
    private var completionHanlderDelete: ((Error?) -> Void)?
    private var completionHandlerInsert: ((Error?) -> Void)?
    
    func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        methodsCalled.append(.save(items: items, timestamp: timestamp))
        completionHandlerInsert = completion
    }
    
    func delete(completion: @escaping (Error?) -> Void) {
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
