import UIKit
import RestaurantDomain
import RestaurantUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var fileManagerURL = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "SunnyDay.store")
    }()
    
    private lazy var localService = {
        let fileManagerURL = fileManagerURL
        let cache = CacheService(manegerURL: fileManagerURL)
        
        return LocalRestaurantLoader(cache: cache, currentDate: Date.init)
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: fileManagerURL)
        }
                
        // composite remote and local
        let compositeService = RestaurantLoaderCompositeRemoteAndLocal(main: makeRemoteLoader(), fallback: localService)
        
        // Decorator side effects Service and insert cache
        let decoratorService = RestaurantLoaderCacheDecorator(decoratee: compositeService, cache: localService)
        
        // UI Presentation
        let controller = RestaurantListCompose.compose(service: decoratorService)
        let navigation = UINavigationController(rootViewController: controller)
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
    }
    
    private func remoteService() -> RestaurantLoader {
        let session = URLSession(configuration: .ephemeral)
        let network = NetworkService(session: session)
        let url = URL(string: "https://raw.githubusercontent.com/comitando/assets/main/api/restaurant_list_endpoint.json")!
        
        return RemoteRestaurantLoader(url: url, networkClient: network)
    }
    
    private func makeRemoteLoader() -> RestaurantLoader {
        switch UserDefaults.standard.string(forKey: "connectivity") {
            case "offline":
                return RestaurantLoaderMock()
            default:
                return remoteService()
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        localService.validateCache()
    }
}

private final class RestaurantLoaderMock: RestaurantLoader {
    func load(completion: @escaping (Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void) {
        completion(.failure(.connectivity))
    }
}


// RemoteService
//        let session = URLSession(configuration: .ephemeral)
//        let network = NetworkService(session: session)
//        let url = URL(string: "https://raw.githubusercontent.com/comitando/assets/main/api/restaurant_list_endpoint.json")!
//        let remoteService = RemoteRestaurantLoader(url: url, networkClient: network)

//        // LocalService
//        let fileManagerURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "SunnyDay.store")
//        let cache = CacheService(manegerURL: fileManagerURL)
//        let localService = LocalRestaurantLoader(cache: cache) {
//            return Date()
//        }
