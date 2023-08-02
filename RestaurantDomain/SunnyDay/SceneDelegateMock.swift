import UIKit
import RestaurantDomain
import RestaurantUI

#if DEBUG
class SceneDelegateMock: SceneDelegate {
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: fileManagerURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeRemoteLoader() -> RestaurantLoader {
        if UserDefaults.standard.string(forKey: "connectivity") == "offline" {
            return RestaurantLoaderMock()
        }
        
        return super.makeRemoteLoader()
    }
}

private final class RestaurantLoaderMock: RestaurantLoader {
    func load(completion: @escaping (Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void) {
        completion(.failure(.connectivity))
    }
}
#endif
