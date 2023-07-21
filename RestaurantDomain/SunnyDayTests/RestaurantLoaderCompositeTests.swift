import XCTest
import RestaurantDomain
@testable import SunnyDay

final class RestaurantLoaderCompositeTests: XCTestCase {
    func test_load_composite_should_be_completion_success_for_main_loader() {
        let main = RestaurantLoaderSpy()
        let fallback = RestaurantLoaderSpy()
        let sut = RestaurantLoaderCompositeRemoteAndLocal(main: main, fallback: fallback)
        
        sut.load { _ in }
        main.completionResult(.success([makeItem(), makeItem()]))
        
        XCTAssertEqual(main.methodsCalled, [.load])
        XCTAssertTrue(fallback.methodsCalled.isEmpty)
    }
    
    func test_load_composite_should_be_completion_success_for_fallback_loader() {
        let main = RestaurantLoaderSpy()
        let fallback = RestaurantLoaderSpy()
        let sut = RestaurantLoaderCompositeRemoteAndLocal(main: main, fallback: fallback)
        
        sut.load { _ in }
        main.completionResult(.failure(.connectivity))
        fallback.completionResult(.success([makeItem()]))
        
        XCTAssertEqual(main.methodsCalled, [.load])
        XCTAssertEqual(fallback.methodsCalled, [.load])
    }
    
    func test_load_composite_should_be_completion_error_when_main_and_fallback_returned_failure() {
        let main = RestaurantLoaderSpy()
        let fallback = RestaurantLoaderSpy()
        let sut = RestaurantLoaderCompositeRemoteAndLocal(main: main, fallback: fallback)
        
        sut.load { _ in }
        main.completionResult(.failure(.connectivity))
        fallback.completionResult(.failure(.connectivity))
        
        XCTAssertEqual(main.methodsCalled, [.load])
        XCTAssertEqual(fallback.methodsCalled, [.load])
    }
}

final class RestaurantLoaderSpy: RestaurantLoader {
    enum Methods: Equatable {
        case load
    }
    
    private(set) var methodsCalled = [Methods]()
    private var completionHandler: ((Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void)?
    
    func load(completion: @escaping (Result<[RestaurantDomain.RestaurantItem], RestaurantDomain.RestaurantResultError>) -> Void) {
        methodsCalled.append(.load)
        completionHandler = completion
    }
    
    func completionResult(_ result: Result<[RestaurantItem], RestaurantResultError>) {
        completionHandler?(result)
    }
}
