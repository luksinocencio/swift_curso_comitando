import XCTest
import SnapshotTesting
import RestaurantDomain
@testable import RestaurantUI


final class RestaurantUISnaphotTests: XCTestCase {
    private let dataModel: [RestaurantItem] = [
        RestaurantItem(id: UUID(), name: "Tenda do quartel", location: "Canto do Forte - Praia Grande", distance: 50, ratings: 4, parasols: 10),
        RestaurantItem(id: UUID(), name: "Tenda do quartel", location: "Canto do Forte - Praia Grande", distance: 50, ratings: 4, parasols: 10),
        RestaurantItem(id: UUID(), name: "Tenda do quartel", location: "Canto do Forte - Praia Grande", distance: 50, ratings: 4, parasols: 10),
        RestaurantItem(id: UUID(), name: "Tenda do quartel", location: "Canto do Forte - Praia Grande", distance: 50, ratings: 4, parasols: 10)
    ]
    
    /// Rodar os tetes com device iPhone 14 Pro
    func test_snapshot_after_render_restaurantItemCell() {
        let controller = RestaurantItemCellController(viewModel: dataModel[0])
        let cell = RestaurantItemCell(style: .default, reuseIdentifier: RestaurantItemCell.identifier)
        
        cell.backgroundColor = .white
        controller.renderCell(cell)
        
        assertSnapshot(matching: cell, as: .image(size: CGSize(width: 375, height: 175)), record: false)
    }
    
    /// Rodar os tetes com device iPhone 14 Pro
    func test_snapshot_render_restaurantListViewController() {
        let (sut, service) = makeSUT()
        let navigation = UINavigationController(rootViewController: sut)
        
        sut.loadViewIfNeeded()
        service.completionResult(.success(dataModel))
     
        assertSnapshot(matching: navigation, as: .image(on: .iPhoneX(.portrait)), record: false)
    }
}

extension RestaurantUISnaphotTests {
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: RestaurantListViewController, service: RestaurantLoaderSpy) {
        let service = RestaurantLoaderSpy()
        let sut = RestaurantListCompose.compose(service: service) as! RestaurantListViewController
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(service, file: file, line: line)
        return (sut, service)
    }
}
