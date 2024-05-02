//
//  OfficeWorkout.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import Foundation
import FirebaseFirestoreSwift

struct OfficeWorkout: Identifiable, Decodable, Encodable {
    @DocumentID var docID : String?
    var id = UUID()
    var name: String
    var repeatTimeHours: Int
    var active = true
}
