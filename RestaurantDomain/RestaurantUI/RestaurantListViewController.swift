import UIKit
import RestaurantDomain

final class RestaurantListViewController: UIViewController {
    private(set) var restaurantCollection: [RestaurantItem] = []
    private var service: RestaurantLoader? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        service?.load(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
                case let .success(items):
                    self.restaurantCollection = items
                default:
                    break
            }
        })
    }
    
    convenience init(service: RestaurantLoader) {
        self.init()
        self.service = service
    }
}
