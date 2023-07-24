import Foundation
import RestaurantDomain

final class RestaurantLoaderCacheDecorator {
    private let decoratee: RestaurantLoader
    private let cache: LocalRestaurantLoaderInsert
    
    init(decoratee: RestaurantLoader, cache: LocalRestaurantLoaderInsert) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
}

extension RestaurantLoaderCacheDecorator: RestaurantLoader {
    func load(completion: @escaping (Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void) {
        decoratee.load { [weak self] result in
            completion(
                result.map { items in
                    self?.cache.save(items, completion: { _ in })
                    return items
                })
        }
    }
}
