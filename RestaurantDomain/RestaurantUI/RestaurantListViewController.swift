import UIKit
import RestaurantDomain

final class RestaurantListViewController: UIViewController {
    
    private(set) var restaurantCollection: [RestaurantItem] = []
    private var service: RestaurantLoader? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        service?.load(completion: { result in
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
