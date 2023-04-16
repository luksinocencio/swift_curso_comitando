import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderTests: XCTestCase {
    func test_save_deletes_olds_cache() {
        let (sut, cache) = makeSUT()
        let items = [RestaurantItem(id: UUID(), name: "any_name", location: "any_location", distance: 5.5, ratings: 0, parasols: 0)]
        
        sut.save(items) { _ in }

        XCTAssertEqual(cache.methodsCalled, [.delete])
    }
    
    func test_save_insert_new_data_on_cache() {
        let currentDate: Date = Date()
        let (sut, cache) = makeSUT()
        let items = [RestaurantItem(id: UUID(), name: "any_name", location: "any_location", distance: 5.5, ratings: 0, parasols: 0)]
    
        sut.save(items) { _ in }
        
        cache.completionHandlerForDelete(nil)
        
        XCTAssertEqual(cache.methodsCalled, [.delete, .save(items: items, timestamp: currentDate)])
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
}

final class CacheClientSpy: CacheClient {
    enum Methods: Equatable {
        case delete
        case save(items: [RestaurantItem], timestamp: Date)
    }
    
    private (set) var methodsCalled = [Methods]()
    private var completionHanlder: ((Error?) -> Void)?
    
    func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        methodsCalled.append(.save(items: items, timestamp: timestamp))
    }
    
    func delete(completion: @escaping (Error?) -> Void) {
        methodsCalled.append(.delete)
        completionHanlder = completion
    }
    
    func completionHandlerForDelete(_ error: Error?) {
        completionHanlder?(error)
    }
}
