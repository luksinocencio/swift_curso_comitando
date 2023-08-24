import XCTest
@testable import RestaurantDomain

final class RestaurantDomainIntegrationTests: XCTestCase {
    func test_load_and_returned_restaurantItem_list() {
        let sut = makeSUT()
        let exp = expectation(description: "esperando retorno do bloco")
        
        sut.load { result in
            switch result {
            case let .success(items):
//                XCTAssertEqual(items.count, 10) //
                
                let item = items.first
                XCTAssertNotNil(item?.name)
                XCTAssertNotNil(item?.location)
                XCTAssertNotNil(item?.distance)
                XCTAssertNotNil(item?.ratings)
                XCTAssertNotNil(item?.parasols)
                
            default:
                XCTFail("Era esperado retorno de listagem")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
    }
    
}

extension RestaurantDomainIntegrationTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> RemoteRestaurantLoader {
        let session = URLSession(configuration: .ephemeral)
        let network = NetworkService(session: session)
        let url = URL(string: "https://raw.githubusercontent.com/comitando/assets/main/api/restaurant_list_endpoint.json")!
        return RemoteRestaurantLoader(url: url, networkClient: network)
    }
}
