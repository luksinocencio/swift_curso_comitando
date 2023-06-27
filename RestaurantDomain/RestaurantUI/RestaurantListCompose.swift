import UIKit
import RestaurantDomain

final class RestaurantListCompose {
    static func compose(service: RestaurantLoader) -> RestaurantListViewController {
        let refreshController = RefreshController(service: service)
        let controller = RestaurantListViewController(refreshController: refreshController)
        refreshController.onRefresh = adapterRestaurantItemCellController(controller: controller)
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


