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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        restaurantCollection.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = restaurantCollection[indexPath.row]
        let cell = RestaurantItemCell()
        
        cell.title.text = viewModel.name
        cell.location.text = viewModel.location
        cell.distance.text = viewModel.distanceToString
        cell.parasols.text = viewModel.parasolToString
        cell.collectionOfRating.enumerated().forEach { (index, image) in
            let systemName = index < viewModel.ratings ? "star.fill" : "star"
            image.image = UIImage(systemName: systemName)
        }
        
        return cell
    }
}

final class RestaurantItemCell: UITableViewCell {
    private(set) var title = UILabel()
    private(set) var location = UILabel()
    private(set) var distance = UILabel()
    private(set) var parasols = UILabel()
    private(set) var collectionOfRating: [UIImageView] = {
        [
            UIImageView(),
            UIImageView(),
            UIImageView(),
            UIImageView(),
            UIImageView()
        ]
    }()
}

private extension RestaurantItem {
    var parasolToString: String {
        return "Guarda-sois: \(parasols)"
    }
    
    var distanceToString: String {
        return "Distância: \(distance)m"
    }
}
