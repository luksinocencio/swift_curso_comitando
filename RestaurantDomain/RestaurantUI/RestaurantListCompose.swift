import UIKit
import RestaurantDomain

final class RestaurantListCompose {
    static func compose(service: RestaurantLoader) -> RestaurantListViewController {
        let presenter = RestaurantListPresenter()
        let interactor = RestaurantListInteractor(service: service, presenter: presenter)
        let controller = RestaurantListViewController(interactor: interactor)
        presenter.view = controller
        controller.title = "Praia do Forte"
        
        return controller
    }
}


