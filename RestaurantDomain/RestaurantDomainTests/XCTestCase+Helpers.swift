import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(
                instance, "A instância deveria ter sido deslocada, possível vazamento de memória",
                file: file,
                line: line
            )
        }
    }
}
