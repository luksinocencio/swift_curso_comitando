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
    private let okResponse: Int = 200
    
    init(url: URL, networkClient: NetworkClient) {
        self.url = url
        self.networkClient = networkClient
    }
    
    private func successfullyValidation(_ data: Data, response: HTTPURLResponse) -> RemoteRestaurantResult {
        guard let json = try? JSONDecoder().decode(RestaurantRoot.self, from: data), response.statusCode == okResponse else {
            return .failure(.invalidData)
        }
        
        return .success(json.items)
    }
    
    func load(completion: @escaping (RemoteRestaurantLoader.RemoteRestaurantResult) -> Void)  {
        let okResponse = okResponse
        
        networkClient.request(from: url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case let .success((data, response)): completion(self.successfullyValidation(data, response: response))
                case .failure: completion(.failure(.connectivity))
            }
        }
    }
}
