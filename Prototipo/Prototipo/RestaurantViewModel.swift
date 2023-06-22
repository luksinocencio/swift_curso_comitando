import Foundation

struct RestaurantViewModel {
    let title: String
    let location: String
    let distance: String
    let parasols: String
    let rating: Int
}

extension RestaurantViewModel {
    static var dataModel = [
        RestaurantViewModel(title: "Tenda do quartel", location: "Canto Forte - Praia Grande", distance: "Distancia 50m", parasols: "Guarda sol (#1)", rating: 4),
        RestaurantViewModel(title: "Tenda do quartel", location: "Canto Forte - Praia Grande", distance: "Distancia 50m", parasols: "Guarda sol (#2)", rating: 2),
        RestaurantViewModel(title: "Tenda do quartel", location: "Canto Forte - Praia Grande", distance: "Distancia 50m", parasols: "Guarda sol (#3)", rating: 3),
        RestaurantViewModel(title: "Tenda do quartel", location: "Canto Forte - Praia Grande", distance: "Distancia 50m", parasols: "Guarda sol (#4)", rating: 4),
    ]
}
