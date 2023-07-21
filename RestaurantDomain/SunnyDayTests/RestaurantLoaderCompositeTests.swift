import XCTest
import RestaurantDomain
@testable import SunnyDay

final class RestaurantLoaderCompositeTests: XCTestCase {
    func test_load_composite_should_be_completion_success_for_main_loader() {
        let result: RestaurantLoader.RestaurantResult = .success([makeItem()])
        let sut = makeSUT(mainResult: result, fallbackResult: .failure(.connectivity))
        
        assert(sut, completion: result)
    }
    
    func test_load_composite_should_be_completion_success_for_fallback_loader() {
        let result: RestaurantLoader.RestaurantResult = .success([makeItem()])
        let sut = makeSUT(mainResult: .failure(.connectivity), fallbackResult: result)
        
        assert(sut, completion: result)
    }
    
    func test_load_composite_should_be_completion_error_when_main_and_fallback_returned_failure() {
        let result: RestaurantLoader.RestaurantResult = .failure(.connectivity)
        let sut = makeSUT(mainResult: .failure(.connectivity), fallbackResult: result)
        
        assert(sut, completion: result)
    }
}

extension RestaurantLoaderCompositeTests {
    private func makeSUT(
        mainResult: RestaurantLoader.RestaurantResult,
        fallbackResult: RestaurantLoader.RestaurantResult,
        file: StaticString = #file,
        line: UInt = #line
    ) -> RestaurantLoader {
        let main = RestaurantLoaderSpy(result: mainResult)
        let fallback = RestaurantLoaderSpy(result: fallbackResult)
        let sut = RestaurantLoaderCompositeRemoteAndLocal(main: main, fallback: fallback)
        
        trackForMemoryLeaks(main)
        trackForMemoryLeaks(fallback)
        trackForMemoryLeaks(sut)
        
        return sut
    }
    
    private func assert(
        _ sut: RestaurantLoader,
        completion result: RestaurantLoader.RestaurantResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "esperando bloco ser completado")
        sut.load { returnedResult in
            switch (result, returnedResult) {
                case let (.success(resultItems), .success(returnItems)):
                    XCTAssertEqual(resultItems, returnItems, file: file, line: line)
                case (.failure, .failure):
                    break
                default:
                    XCTFail("Esperado \(returnedResult), porem retornou \(returnedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}

final class RestaurantLoaderSpy: RestaurantLoader {
    private let result: RestaurantResult
    
    init(result: RestaurantResult) {
        self.result = result
    }
    
    func load(completion: @escaping (Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void) {
        completion(result)
    }
}
