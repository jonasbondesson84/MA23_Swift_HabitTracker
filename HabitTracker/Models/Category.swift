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

extension Category {
    static let emptyCategory = Category(name: "Running", image: "figure.walk")
}

