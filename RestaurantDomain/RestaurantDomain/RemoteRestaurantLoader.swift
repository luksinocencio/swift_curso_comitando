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
 1. O sistema entrega um erro.
 #### Sem conectividade - caminho triste:
 1. O sistema entrega um erro.
 */

import Foundation

final class NetworkClient {
    static let shared: NetworkClient = NetworkClient()
    private(set) var urlRequest: URL?
    
    private init() { }
    
    func request(from url: URL) {
        urlRequest = url
    }
}

final class RemoteRestaurantLoader {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func load() {
        NetworkClient.shared.request(from: url)
    }
}
