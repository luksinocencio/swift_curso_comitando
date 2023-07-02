import UIKit
import RestaurantDomain

final class RestaurantListCompose {
    static func compose(service: RestaurantLoader) -> RestaurantListViewController {
        let decorator = MainQueueDispatchDecorator(decoratee: service)
        let presenter = RestaurantListPresenter()
        let interactor = RestaurantListInteractor(service: decorator, presenter: presenter)
        let controller = RestaurantListViewController(interactor: interactor)
        presenter.view = controller
        controller.title = "Praia do Forte"
        
        return controller
    }
}


final class MainQueueDispatchDecorator: RestaurantLoader {
    private let decoratee: RestaurantLoader
    
    init(decoratee: RestaurantLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void) {
        decoratee.load { result in
            DispatchQueue.main.safeAsync {
                completion(result)
            }
        }
    }
}

extension DispatchQueue {
    func safeAsync(_ block: @escaping () -> Void) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
