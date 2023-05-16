import Foundation

protocol CacheClient {
    func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping(Error?) -> Void)
    func delete(completion: @escaping (Error?) -> Void)
}

final class LocalRestaurantLoader {
    let cache: CacheClient
    let currentDate: () -> Date
    
    init(cache: CacheClient, currentDate: @escaping () -> Date) {
        self.cache = cache
        self.currentDate = currentDate
    }
    
    func save(_ items: [RestaurantItem], completion: @escaping (Error?) -> Void) {
        cache.delete { [weak self] error in
            guard let self else { return }
            if error == nil {
                self.cache.save(items, timestamp: self.currentDate()) { [weak self] error in
                    guard let self else { return }
                    completion(error)
                }
            } else {
                completion(error)
            }
        }
    }
}
