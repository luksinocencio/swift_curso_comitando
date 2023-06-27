import UIKit
import RestaurantDomain

final class RefreshController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return refreshControl
    }()
    
    private let service: RestaurantLoader
    
    init(service: RestaurantLoader) {
        self.service = service
    }
    
    var onRefresh: (([RestaurantItem]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        
        service.load(completion: { [weak self] result in
            switch result {
                case let .success(items):
                    self?.onRefresh?(items)
                default:
                    break
            }
            
            self?.view.endRefreshing()
        })
    }
}
