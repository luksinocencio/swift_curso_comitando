import Foundation
import XCTest

@testable import RestaurantDomain

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
        
    func makeItem() -> RestaurantItem {
        RestaurantItem(id: UUID(), name: "any_name", location: "any_location", distance: 5.5, ratings: 0, parasols: 0)
    }
}

extension Date {
    func addind(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}

