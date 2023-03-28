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

struct RestaurantItem {
    let id: UUID
    let name: String
    let location: String
    let distance: String
    let ratings: Int
    let parasols: Int
}

protocol NetworkClient {
    typealias NetworkResult = Result<(Data, HTTPURLResponse), Error>
    func request(from url: URL, completion: @escaping (NetworkResult) -> Void)
}

final class RemoteRestaurantLoader {
    let url: URL
    let networkClient: NetworkClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    init(url: URL, networkClient: NetworkClient) {
        self.url = url
        self.networkClient = networkClient
    }
    
    func load(completion: @escaping (RemoteRestaurantLoader.Error) -> Void)  {
        networkClient.request(from: url) { result in
            switch result {
                case .success: completion(.invalidData)
                case .failure: completion(.connectivity)
            }
        }
    }
}
