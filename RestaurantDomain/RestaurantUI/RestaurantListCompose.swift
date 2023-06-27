import UIKit
import RestaurantDomain

final class RestaurantListCompose {
    static func compose(service: RestaurantLoader) -> RestaurantListViewController {
        let viewModel = RestaurantListViewModel(service: service)
        let refreshController = RefreshController(viewModel: viewModel)
        let controller = RestaurantListViewController(refreshController: refreshController)
        viewModel.onRestaurantItem = adapterRestaurantItemCellController(controller: controller)
        return controller
    }
    
    static func adapterRestaurantItemCellController(
        controller: RestaurantListViewController
    ) -> (([RestaurantItem]) -> Void) {
        return { [weak controller] items in
            controller?.restaurantCollection = items.map { RestaurantItemCellController(viewModel: $0) }
        }
    }
}


