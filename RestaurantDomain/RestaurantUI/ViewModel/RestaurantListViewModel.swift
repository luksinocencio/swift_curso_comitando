import Foundation
import RestaurantDomain

final class RestaurantListViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let service: RestaurantLoader
    
    init(service: RestaurantLoader) {
        self.service = service
    }
    
    var onLoadingState: Observer<Bool>?
    var onRestaurantItem: Observer<[RestaurantItem]>?
    
    func loadService() {
        onLoadingState?(true)
        
    }
}
