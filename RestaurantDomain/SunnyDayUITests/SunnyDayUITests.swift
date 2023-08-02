import XCTest

final class SunnyDayUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func test_launch_should_be_show_remote_data_with_client_have_connectivity() {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertEqual(app.cells.count, 10)
        XCTAssertEqual(app.cells.firstMatch.staticTexts.count, 4)
    }
}
