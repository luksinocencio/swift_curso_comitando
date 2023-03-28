/**
 ### Caso de Uso de RemoteRestaurantLoader
 
 #### Dados (Entrada):
 - URL
 
 #### Caminho feliz:
 1. Execute o comando "Carregar listagem de restaurantes" com os dados acima.
 2. O sistema baixa dados da URL.
 3. O sistema valida os dados baixados.
 4. O sistema cria itens de restaurante a partir de dados válidos
 5. O sistema entrega uma lista de restaurantes.
 
 #### Dados inválidos - caminho triste:
 ✅ 1. O sistema entrega um erro.
 
 #### Sem conectividade - caminho triste:
 ✅ 1. O sistema entrega um erro.
 */

import Foundation

struct RestaurantItem: Decodable, Equatable {
    let id: UUID
    let name: String
    let location: String
    let distance: Float
    let ratings: Int
    let parasols: Int
}

struct RestaurantRoot: Decodable {
    let items: [RestaurantItem]
}

protocol NetworkClient {
    typealias NetworkResult = Result<(Data, HTTPURLResponse), Error>
    func request(from url: URL, completion: @escaping (NetworkResult) -> Void)
}

final class RemoteRestaurantLoader {
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    typealias RemoteRestaurantResult = Result<[RestaurantItem], RemoteRestaurantLoader.Error>
    
    let url: URL
    let networkClient: NetworkClient
    
    init(url: URL, networkClient: NetworkClient) {
        self.url = url
        self.networkClient = networkClient
    }
    
    func load(completion: @escaping (RemoteRestaurantLoader.RemoteRestaurantResult) -> Void)  {
        networkClient.request(from: url) { result in
            switch result {
                case let .success((data, _)):
                    guard let json = try? JSONDecoder().decode(RestaurantRoot.self, from: data) else {
                        return completion(.failure(.invalidData))
                    }
                    completion(.success(json.items))
                case .failure: completion(.failure(.connectivity))
            }
        }
    }
}
