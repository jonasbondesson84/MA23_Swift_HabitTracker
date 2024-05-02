//
//  OfficeWorkout.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import Foundation

struct OfficeWorkout: Identifiable, Decodable, Encodable {
    var id = UUID()
    var name: String
    var repeatTimeHours: Int
    var active = true
}
