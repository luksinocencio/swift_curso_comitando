import Foundation
import RestaurantDomain

final class RestaurantListViewModel {
    private let service: RestaurantLoader
    
    init(service: RestaurantLoader) {
        self.service = service
    }
    
    var onLoadingState: ((Bool) -> Void)?
    var onRestaurantItem: (([RestaurantItem]) -> Void)?
    
    func loadService() {
        onLoadingState?(true)
        service.load { [weak self]result in
            switch result {
                case let .success(items):
                    self?.onRestaurantItem?(items)
                default: break
            }
            self?.onLoadingState?(false)
        }
    }
}
