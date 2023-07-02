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


final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
    
//    func load(completion: @escaping (Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void) {
//        decoratee.load { result in
//            DispatchQueue.main.safeAsync {
//                completion(result)
//            }
//        }
//    }
}

//extension DispatchQueue {
//    func safeAsync(_ block: @escaping () -> Void) {
//        if self === DispatchQueue.main && Thread.isMainThread {
//            block()
//        } else {
//            async { block() }
//        }
//    }
//}

extension MainQueueDispatchDecorator: RestaurantLoader where T == RestaurantLoader {
    func load(completion: @escaping (Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
