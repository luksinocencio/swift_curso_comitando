import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderTests: XCTestCase {
    func test_save_deletes_olds_cache() {
        let currentDate = Date()
        let cache = CacheClientSpy()
        let sut = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })
        let items = [RestaurantItem(id: UUID(), name: "any_name", location: "any_location", distance: 5.5, ratings: 0, parasols: 0)]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(cache.deleteCount, 1)
    }
    
    func test_save_insert_new_data_on_cache() {
        let currentDate = Date()
        let cache = CacheClientSpy()
        let sut = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })
        let items = [RestaurantItem(id: UUID(), name: "any_name", location: "any_location", distance: 5.5, ratings: 0, parasols: 0)]
        
        sut.save(items) { _ in }
        
        cache.completionHandlerForDelete(nil)
        
        XCTAssertEqual(cache.deleteCount, 1)
        XCTAssertEqual(cache.saveCount, 1)
    }
}

final class CacheClientSpy: CacheClient {
    private (set) var saveCount = 0
    
    func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        saveCount += 1
    }
    
    private (set) var deleteCount = 0
    private var completionHanlder: ((Error?) -> Void)?
    
    func delete(completion: @escaping (Error?) -> Void) {
        deleteCount += 1
        completionHanlder = completion
    }
    
    func completionHandlerForDelete(_ error: Error?) {
        completionHanlder?(error)
    }
}
