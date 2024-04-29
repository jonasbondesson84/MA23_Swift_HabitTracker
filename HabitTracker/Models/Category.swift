//
//  Category.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import Foundation


struct Category: Identifiable, Decodable, Encodable, Hashable {
    var id = UUID()
    let name : String
    let image : String
}

enum CategoryEnum : Hashable{
    case category(Category)
    
    static var allCategories: [CategoryEnum] {
        return [
            .category(Category(name: "Running", image: "figure.run")),
            .category(Category(name: "Swimming", image: "figure.pool.swim")),
            .category(Category(name: "Cycling", image: "figure.outdoor.cycle")),
            .category(Category(name: "Walking", image: "figure.walk"))
            // Lägg till fler kategorier efter behov
        ]
    }
}
