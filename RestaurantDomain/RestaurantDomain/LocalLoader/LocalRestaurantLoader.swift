import Foundation

public enum LoadResultState {
    case empty
    case success(items: [RestaurantItem], timestamp: Date)
    case failure(Error)
}

protocol CacheClient {
    typealias SaveResult = (Error?) -> Void
    typealias DeleteResult = (Error?) -> Void
    typealias LoadResult = (LoadResultState) -> Void
    
    func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping SaveResult)
    func delete(completion: @escaping DeleteResult)
    func load(completion: @escaping LoadResult)
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
            guard let error = error else {
                return self.saveOnCache(items, completion: completion)
            }
            completion(error)
        }
    }
    
    private func saveOnCache(_ items: [RestaurantItem], completion: @escaping (Error?) -> Void) {
        cache.save(items, timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

extension LocalRestaurantLoader: RestaurantLoader {
    func load(completion: @escaping (Result<[RestaurantItem], RestaurantResultError>) -> Void) {
        cache.load { state in
            switch state {
            case .empty:
                completion(.success([]))
            case let .success(items, _):
                completion(.success(items))
            case .failure:
                completion(.failure(.invalidData))
            }
        }
    }
}
