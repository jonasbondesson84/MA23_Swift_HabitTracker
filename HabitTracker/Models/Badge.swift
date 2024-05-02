//
//  Badge.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//


import Foundation

struct Badge : Identifiable, Encodable, Decodable {
    var id = UUID()
    var name: String
    var streak: Int
    var category: String
    var image: String
}
