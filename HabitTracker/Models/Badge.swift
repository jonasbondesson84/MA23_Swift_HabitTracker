//
//  Badge.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//


import Foundation

struct Badge : Identifiable {
    var id = UUID()
    var name: String
    var category: String
    var image: String
}
