import Foundation
@testable import RestaurantDomain

final class CacheClientSpy: CacheClient {
    enum Methods: Equatable {
        case delete
        case save(items: [RestaurantItem], timestamp: Date)
        case load
    }
    
    private (set) var methodsCalled = [Methods]()
    private var completionHanlderDelete: (CacheClient.DeleteResult)?
    private var completionHandlerInsert: (CacheClient.SaveResult)?
    private var completionHandlerLoad: (CacheClient.LoadResult)?
    
    func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping CacheClient.SaveResult) {
        methodsCalled.append(.save(items: items, timestamp: timestamp))
        completionHandlerInsert = completion
    }
    
    func delete(completion: @escaping CacheClient.DeleteResult) {
        methodsCalled.append(.delete)
        completionHanlderDelete = completion
    }
    
    func load(completion: @escaping LoadResult) {
        methodsCalled.append(.load)
        completionHandlerLoad = completion
    }
    
    func completionHandlerForDelete(_ error: Error?) {
        completionHanlderDelete?(error)
    }
    
    func completionHandlerForInsert(_ error: Error?) {
        completionHanlderDelete?(error)
    }
    
    func completionHandlerForLoad(_ state: LoadResultState) {
        completionHandlerLoad?(state)
    }
}
