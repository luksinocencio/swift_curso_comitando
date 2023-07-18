import Foundation

public enum LoadResultState {
    case empty
    case success(items: [RestaurantItem], timestamp: Date)
    case failure(Error)
}

public protocol CacheClient {
    typealias SaveResult = (Error?) -> Void
    typealias DeleteResult = (Error?) -> Void
    typealias LoadResult = (LoadResultState) -> Void
    
    func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping SaveResult)
    func delete(completion: @escaping DeleteResult)
    func load(completion: @escaping LoadResult)
}

public final class CacheService: CacheClient {
    
    private struct Cache: Codable {
        let items: [RestaurantItem]
        let timestamp: Date
    }
    private let manegerURL: URL
    private let callbackQueue = DispatchQueue(
        label: "\(CacheService.self).CallbackQueue",
        qos: .userInitiated,
        attributes: .concurrent
    )
    
    public init(manegerURL: URL) {
        self.manegerURL = manegerURL
    }
    
    public func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping SaveResult) {
        callbackQueue.async(flags: .barrier) {
            do {
                let cache = Cache(items: items, timestamp: timestamp)
                let enconder = JSONEncoder()
                let encodend = try enconder.encode(cache)
                try encodend.write(to: self.manegerURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func delete(completion: @escaping DeleteResult) {
        callbackQueue.async {
            guard FileManager.default.fileExists(atPath: self.manegerURL.path) else {
                return completion(nil)
            }
            do {
                try FileManager.default.removeItem(at: self.manegerURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func load(completion: @escaping LoadResult) {
        callbackQueue.async {
            guard let data = try? Data(contentsOf: self.manegerURL) else {
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
}
