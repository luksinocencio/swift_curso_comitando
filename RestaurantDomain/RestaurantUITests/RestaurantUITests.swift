import XCTest
import RestaurantDomain

@testable import RestaurantUI

final class RestaurantUITests: XCTestCase {
    func test_init_does_not_load() {
        let (sut, service) = makeSUT()
        
        XCTAssertTrue(service.methodsCalled.isEmpty)
        XCTAssertTrue(sut.restaurantCollection.isEmpty)
    }
    
    func test_viewDidLoad_should_be_called_load_service() {
        let (sut, service) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(service.methodsCalled, [.load])
    }
    
    func test_load_returned_restaurantItems_data_and_restaurantCollection_does_not_empty() {
        let (sut, service) = makeSUT()
        
        sut.loadViewIfNeeded()
        service.completionResult(.success([makeItem()]))
        
        XCTAssertEqual(service.methodsCalled, [.load])
        XCTAssertEqual(sut.restaurantCollection.count, 1)
    }
    
    func test_load_returned_error_and_restaurantCollection_is_empty() {
        let (sut, service) = makeSUT()
        
        sut.loadViewIfNeeded()
        service.completionResult(.failure(.connectivity))
        
        XCTAssertEqual(service.methodsCalled, [.load])
        XCTAssertEqual(sut.restaurantCollection.count, 0)
    }
    
    func test_pullToRefresh_should_be_called_load_service() {
        let (sut, service) = makeSUT()
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(service.methodsCalled, [.load, .load])
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(service.methodsCalled, [.load, .load, .load])
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(service.methodsCalled, [.load, .load, .load, .load])
    }
    
    func test_load_when_completion_failure_should_be_hide_loading_indicator() {
        let (sut, service) = makeSUT()
        
        sut.loadViewIfNeeded()
        service.completionResult(.failure(.connectivity))
        
        XCTAssertEqual(sut.isShowLoadingIndicator, false)
    }
    
    func test_load_when_completion_success_should_be_hide_loading_indicator() {
        let (sut, service) = makeSUT()
        
        sut.loadViewIfNeeded()
        service.completionResult(.success([makeItem()]))
        
        XCTAssertEqual(sut.isShowLoadingIndicator, false)
    }
    
    func test_pullToRefresh_should_be_show_loading_indicator() {
        let (sut, _) = makeSUT()
        
        sut.simulatePullToRefresh()
        
        XCTAssertEqual(sut.isShowLoadingIndicator, true)
    }
    
    func test_pullToRefresh_should_be_hide_loading_indicator_when_service_completion_failure() {
        let (sut, service) = makeSUT()
        
        sut.simulatePullToRefresh()
        service.completionResult(.failure(.connectivity))
        
        XCTAssertEqual(sut.isShowLoadingIndicator, false)
    }
    
    func test_show_loading_indicator_for_all_life_cycle_view() {
        let (sut, service) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowLoadingIndicator, true)
        service.completionResult(.failure(.connectivity))
        XCTAssertEqual(sut.isShowLoadingIndicator, false)
        
        sut.simulatePullToRefresh()
        XCTAssertEqual(sut.isShowLoadingIndicator, true)
        service.completionResult(.success([makeItem()]))
        XCTAssertEqual(sut.isShowLoadingIndicator, false)
    }
    
    func test_render_all_restaurant_information_in_view() {
        let (sut, service) = makeSUT()
        let item = makeItem()
        sut.loadViewIfNeeded()
        service.completionResult(.success([item]))
        
        XCTAssertEqual(sut.numberOfRows(), 1)
        
        let cell = sut.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as? RestaurantItemCell
        XCTAssertNotNil(cell)
        XCTAssertEqual(cell?.title.text, item.name)
        XCTAssertEqual(cell?.parasols.text, "Guarda-sois: \(item.parasols)")
        XCTAssertEqual(cell?.distance.text, "Distância: \(item.distance)m")
    }
}

extension RestaurantUITests {
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: RestaurantListViewController, service: RestaurantLoaderSpy) {
        let service = RestaurantLoaderSpy()
        let sut = RestaurantListViewController(service: service)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(service, file: file, line: line)
        return (sut, service)
    }
}

final class RestaurantLoaderSpy: RestaurantLoader {
    enum Methods: Equatable {
        case load
    }
    
    private(set) var methodsCalled = [Methods]()
    private(set) var loadCount = 0
    private var completionLoadHandler: ((RestaurantResult) -> Void)?
    
    func load(completion: @escaping (RestaurantResult) -> Void) {
        loadCount += 1
        methodsCalled.append(.load)
        completionLoadHandler = completion
    }
    
    func completionResult(_ result: RestaurantResult) {
        completionLoadHandler?(result)
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension RestaurantListViewController {
    func simulatePullToRefresh() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowLoadingIndicator: Bool {
        return refreshControl?.isRefreshing ?? false
    }
    
    func numberOfRows() -> Int {
        return tableView.numberOfRows(inSection: 0)
    }
}
