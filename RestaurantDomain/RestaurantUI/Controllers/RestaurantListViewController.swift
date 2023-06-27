import UIKit

final class RestaurantListViewController: UITableViewController {
    private(set) var restaurantCollection: [RestaurantItemCellController] = []
    
    private var interactor: RestaurantListInteractorInput?
    
    convenience init(interactor: RestaurantListInteractorInput) {
        self.init()
        self.interactor = interactor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refresh()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        restaurantCollection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return restaurantCollection[indexPath.row].renderCell()
    }
    
    @objc func refresh() {
        interactor?.loadService()
    }
}

extension RestaurantListViewController: RestaurantListPresenterOutput {
    func onLoadingChange(_ isLoading: Bool) {
        if isLoading {
            self.refreshControl?.beginRefreshing()
        } else {
            self.refreshControl?.endRefreshing()
        }
    }
    
    func onRestaurantItemCell(_ items: [RestaurantItemCellController]) {
        restaurantCollection = items
        tableView.reloadData()
    }
}
