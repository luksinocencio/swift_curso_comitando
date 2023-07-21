import Foundation
import RestaurantDomain

final class RestaurantLoaderCompositeRemoteAndLocal {
    private let main: RestaurantLoader
    private let fallback: RestaurantLoader
    
    init(main: RestaurantLoader, fallback: RestaurantLoader) {
        self.main = main
        self.fallback = fallback
    }
}

extension RestaurantLoaderCompositeRemoteAndLocal: RestaurantLoader {
    func load(completion: @escaping (Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void) {
        main.load { [weak self] result in
            guard let self else { return }
            switch result {
                case let .success(items):
                    completion(.success(items))
                case .failure:
                    self.fallback.load(completion: completion)
            }
        }
    }
}
