import UIKit

class ViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RestaurantViewModel.dataModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = RestaurantViewModel.dataModel[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantItemCell", for: indexPath) as? RestaurantItemCell else {
            return UITableViewCell()
        }
        
        cell.title.text = viewModel.title
        cell.location.text = viewModel.location
        cell.parasols.text = viewModel.parasols
        cell.collectionOfRating.enumerated().forEach { (index, image) in
            let systemName = index < viewModel.rating ? "star.fill" : "star"
            image.image = UIImage(systemName: systemName)
        }
        
        return cell
    }
}

final class RestaurantItemCell: UITableViewCell {
    @IBOutlet private(set) var title: UILabel!
    @IBOutlet private(set) var location: UILabel!
    @IBOutlet private(set) var distance: UILabel!
    @IBOutlet private(set) var parasols: UILabel!
    @IBOutlet private(set) var collectionOfRating: [UIImageView]!
}
