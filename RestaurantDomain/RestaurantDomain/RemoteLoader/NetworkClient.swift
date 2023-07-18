import Foundation

public protocol NetworkClient {
    typealias NetworkResult = Result<(Data, HTTPURLResponse), Error>
    func request(from url: URL, completion: @escaping (NetworkResult) -> Void)
}

public final class NetworkService: NetworkClient {
    private let session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func request(from url: URL, completion: @escaping (NetworkResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                let error = NSError(domain: "unexpected values", code: -1)
                completion(.failure(error))
            }
        }.resume()
    }
}
