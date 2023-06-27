import UIKit
import RestaurantDomain

final class RefreshController: NSObject {
    private(set) lazy var view: UIRefreshControl = setupRefreshControl(UIRefreshControl())
    
    private let viewModel: RestaurantListViewModel
    
    init(viewModel: RestaurantListViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadService()
    }
    
    func setupRefreshControl(_ refreshControl: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingState = { [weak self] loading in
            if loading {
                self?.view.beginRefreshing()
            } else {
                self?.view.endRefreshing()
            }
        }
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return refreshControl
    }
}
