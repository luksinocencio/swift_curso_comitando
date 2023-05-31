import Foundation

protocol CachePolicy {
    func validate(_ timestamp: Date, with currentData: Date) -> Bool
}

final class RestaurantLoaderCachePolicy: CachePolicy {
    
    private let maxAge: Int = 1
    
    public init() { }
    
    func validate(_ timestamp: Date, with currentData: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxAge = calendar.date(byAdding: .day, value: maxAge, to: timestamp) else { return false }
        
        return currentData < maxAge
    }
}
