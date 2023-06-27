import UIKit
import RestaurantDomain

final class RestaurantItemCellController {
    let viewModel: RestaurantItem
    
    init(viewModel: RestaurantItem) {
        self.viewModel = viewModel
    }
    
    func renderCell() -> UITableViewCell {
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

private extension RestaurantItem {
    var parasolToString: String {
        return "Guarda-sois: \(parasols)"
    }
    
    var distanceToString: String {
        return "Distância: \(distance)m"
    }
}
