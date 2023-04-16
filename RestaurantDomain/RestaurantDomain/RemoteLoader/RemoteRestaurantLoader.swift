import Foundation

struct RestaurantRoot: Decodable {
    let items: [RestaurantItem]
}

public final class RemoteRestaurantLoader {
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias RemoteRestaurantResult = Result<[RestaurantItem], RemoteRestaurantLoader.Error>
    
    let url: URL
    let networkClient: NetworkClient
    private let okResponse: Int = 200
    
    public init(url: URL, networkClient: NetworkClient) {
        self.url = url
        self.networkClient = networkClient
    }
    
    private func successfullyValidation(_ data: Data, response: HTTPURLResponse) -> RemoteRestaurantResult {
        guard let json = try? JSONDecoder().decode(RestaurantRoot.self, from: data), response.statusCode == okResponse else {
            return .failure(.invalidData)
        }
        
        return .success(json.items)
    }
    
    public func load(completion: @escaping (RemoteRestaurantLoader.RemoteRestaurantResult) -> Void)  {
        networkClient.request(from: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case let .success((data, response)): completion(self.successfullyValidation(data, response: response))
                case .failure: completion(.failure(.connectivity))
            }
        }
    }
}
