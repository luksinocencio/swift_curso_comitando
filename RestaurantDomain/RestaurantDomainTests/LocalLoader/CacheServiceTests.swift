import XCTest
@testable import RestaurantDomain

final class CacheServiceTests: XCTestCase {
    func test_save_and_returned_last_entered_value() {
        let sut = makeSUT()
        let items = [makeItem(), makeItem()]
        let timestamp = Date()
       
        insert(sut, items: items, timestamp: timestamp)
        assert(sut, completion: .success(items: items, timestamp: timestamp))
    }
    
    func test_save_twice_and_returned_last_entered_value() {
        let sut = makeSUT()
        
        let firstTimeItems = [makeItem(), makeItem()]
        let firstTimeTimestamp = Date()
        insert(sut, items: firstTimeItems, timestamp: firstTimeTimestamp)
        
        let secondTimeItems = [makeItem(), makeItem()]
        let secondTimeTimestamp = Date()
        insert(sut, items: secondTimeItems, timestamp: secondTimeTimestamp)
        
        assert(sut, completion: .success(items: secondTimeItems, timestamp: secondTimeTimestamp))
    }
    
    func test_save_returned_error_when_invalid_manager_url() {
        let managerURL = invalidManagerURL()
        let sut = makeSUT(managerURL: managerURL)
        
        let firstTimeItems = [makeItem(), makeItem()]
        let firstTimeTimestamp = Date()
        let returnedError = insert(sut, items: firstTimeItems, timestamp: firstTimeTimestamp)
        
        XCTAssertNotNil(returnedError)
    }
}

extension CacheServiceTests {
    @discardableResult
    private func insert(_ sut: CacheClient, items: [RestaurantItem], timestamp: Date) -> Error? {
        let exp = expectation(description: "esperando bloco ser completado")
        var resultError: Error?
        
        sut.save(items, timestamp: timestamp) { error in
            resultError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return resultError
    }
    
    private func assert(
        _ sut: CacheClient,
        completion result: LoadResultState,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "esperando bloco ser completado")
        
        sut.load { returnedResult in
            switch (result, returnedResult) {
                case ( .empty, .empty), (.failure, .failure): break
                case let (.success(items, timestamp), .success(returnedItems, returnedTimestamp)):
                    XCTAssertEqual(returnedItems, items, file: file, line: line)
                    XCTAssertEqual(returnedTimestamp, timestamp, file: file, line: line)
                default:
                    XCTFail("Espero retorno \(result), porem retornou \(returnedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(managerURL: URL? = nil) -> CacheService {
        return CacheService(manegerURL: managerURL ?? validManagerURL())
    }
    
    private func validManagerURL() -> URL {
        let path = type(of: self)
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(path)")
    }
    
    private func invalidManagerURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
