import XCTest
@testable import RestaurantDomain

final class NetworkServiceTests: XCTestCase {
    func test_loadRequest_resume_dataTask_with_url() {
        let (sut, session) = makeSUT()
        let url = URL(string: "https://comitando.com.br")!
        let task = URLSessionDataTaskSpy()
        
        session.stub(url: url, task: task)
        sut.request(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    func test_loadRequest_and_completion_with_error() {
        let (sut, session) = makeSUT()
        let url = URL(string: "https://comitando.com.br")!
        let task = URLSessionDataTaskSpy()
        
        let anyError = NSError(domain: "any Error", code: -1)
        session.stub(url: url, task: task, error: anyError)
        
        let exp = expectation(description: "aguardando retorno da clousure")
        sut.request(from: url) { result in
            switch result {
                case let .failure(returnedError):
                    XCTAssertEqual(returnedError as NSError, anyError)
                default:
                    XCTFail("Esperado falha, porem retornou \(result)")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadRequest_and_completion_with_success() {
        let (sut, session) = makeSUT()
        let url = URL(string: "https://comitando.com.br")!
        let task = URLSessionDataTaskSpy()
        
        let data = Data()
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        session.stub(url: url, task: task, data: data, response: response)
        
        let exp = expectation(description: "aguardando retorno da clousure")
        sut.request(from: url) { result in
            switch result {
                case let .success((returnedData, returnedResponse)):
                    XCTAssertEqual(returnedData, data)
                    XCTAssertEqual(returnedResponse, response)
                default:
                    XCTFail("Esperado sucesso, porem retornou \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    
}

extension NetworkServiceTests {
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: NetworkClient, session: URLSessionSpy) {
        let session = URLSessionSpy()
        let sut = NetworkService(session: session)
        trackForMemoryLeaks(session)
        trackForMemoryLeaks(sut)
        
        return (sut, session)
    }
    
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "A instância deveria ter sido deslocada, possível vazamento de memória", file: file, line: line)
        }
    }
}

final class URLSessionSpy: URLSession {
    private(set) var stubs: [URL: Stub] = [:]
    
    struct Stub {
        let task: URLSessionDataTask
        let error: Error?
        let data: Data?
        let response: HTTPURLResponse?
    }
    
    func stub(url: URL, task: URLSessionDataTask, error: Error? = nil, data: Data? = nil, response: HTTPURLResponse? = nil) {
        stubs[url] = Stub(task: task, error: error, data: data, response: response)
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        guard let stub = stubs[url] else { return URLSessionDataTaskSpy() }
        completionHandler(stub.data, stub.response, stub.error)
        return stub.task
    }
}

final class URLSessionDataTaskSpy: URLSessionDataTask {
    private(set) var resumeCount = 0
    
    override func resume() {
        resumeCount += 1
    }
}

final class FakeURLSessionDataTask: URLSessionDataTask {
    override func resume() { }
}
