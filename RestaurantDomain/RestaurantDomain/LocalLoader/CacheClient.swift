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

final class CacheService: CacheClient {
    
    private struct Cache: Codable {
        let items: [RestaurantItem]
        let timestamp: Date
    }
    private let manegerURL: URL
    
    init(manegerURL: URL) {
        self.manegerURL = manegerURL
    }
    
    func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping SaveResult) {
        do {
            let cache = Cache(items: items, timestamp: timestamp)
            let enconder = JSONEncoder()
            let encodend = try enconder.encode(cache)
            try encodend.write(to: manegerURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func delete(completion: @escaping DeleteResult) {
        guard FileManager.default.fileExists(atPath: manegerURL.path) else {
            return completion(nil)
        }
        do {
            try FileManager.default.removeItem(at: manegerURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func load(completion: @escaping LoadResult) {
        guard let data = try? Data(contentsOf: manegerURL) else {
            return completion(.empty)
        }
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.success(items: cache.items, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
}
