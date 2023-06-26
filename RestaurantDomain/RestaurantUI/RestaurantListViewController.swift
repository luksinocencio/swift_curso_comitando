import UIKit
import RestaurantDomain

final class RestaurantListViewController: UITableViewController {
    private(set) var restaurantCollection: [RestaurantItem] = []
    private var service: RestaurantLoader? = nil
    
    convenience init(service: RestaurantLoader) {
        self.init()
        self.service = service
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        loadService()
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadService), for: .valueChanged)
    }
    
    @objc func loadService() {
        refreshControl?.beginRefreshing()
        service?.load(completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
                case let .success(items):
                    self.restaurantCollection = items
                default:
                    break
            }
            
            self.refreshControl?.endRefreshing()
        })
    }
}
