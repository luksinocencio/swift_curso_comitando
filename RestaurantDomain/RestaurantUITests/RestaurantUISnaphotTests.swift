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
    
    func test_snapshot_after_render_restaurantItemCell() {
        let controller = RestaurantItemCellController(viewModel: dataModel[0])
        let cell = RestaurantItemCell(style: .default, reuseIdentifier: RestaurantItemCell.identifier)
        cell.backgroundColor = .white
        controller.renderCell(cell)
        assertSnapshot(matching: cell, as: .image(size: CGSize(width: 375, height: 175)))
    }
}

extension RestaurantUISnaphotTests {
    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: RestaurantListViewController, service: RestaurantLoaderSpy) {
        let service = RestaurantLoaderSpy()
        let sut = RestaurantListCompose.compose(service: service)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(service, file: file, line: line)
        return (sut, service)
    }
}
