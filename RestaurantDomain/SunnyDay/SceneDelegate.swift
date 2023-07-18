import UIKit
import RestaurantDomain
import RestaurantUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let session = URLSession(configuration: .ephemeral)
        // Online
        let network = NetworkService(session: session)
        let url = URL(string: "https://raw.githubusercontent.com/comitando/assets/main/api/restaurant_list_endpoint.json")!
        let service = RemoteRestaurantLoader(url: url, networkClient: network)
        
        // Local
        let fileManagerURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appending(path: "SunnyDay.store")
        let cache = CacheService(manegerURL: fileManagerURL)
        let localService = LocalRestaurantLoader(cache: cache) {
            return Date()
        }
        
        let controller = RestaurantListCompose.compose(service: localService)
        let navigation = UINavigationController(rootViewController: controller)
        window?.rootViewController = navigation
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

