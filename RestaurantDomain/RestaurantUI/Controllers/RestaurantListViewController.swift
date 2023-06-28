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
        tableView.register(RestaurantItemCell.self, forCellReuseIdentifier: RestaurantItemCell.identifier)
        refresh()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        restaurantCollection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantItemCell.identifier, for: indexPath) as? RestaurantItemCell else {
            return UITableViewCell()
        }
        
        restaurantCollection[indexPath.row].renderCell(cell)
        
        return cell
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
