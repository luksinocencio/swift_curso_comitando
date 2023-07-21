import UIKit
import RestaurantDomain

public final class RestaurantListCompose {
    public static func compose(service: RestaurantLoader) -> UITableViewController {
        let decorator = MainQueueDispatchDecorator(decoratee: service)
        let presenter = RestaurantListPresenter()
        let interactor = RestaurantListInteractor(service: decorator, presenter: presenter)
        let controller = RestaurantListViewController(interactor: interactor)
        presenter.view = controller
        controller.title = "Praia do Forte"
        
        return controller
    }
}

extension MainQueueDispatchDecorator: RestaurantLoader where T == RestaurantLoader {
    public func load(completion: @escaping (Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
