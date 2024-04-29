//
//  Activity.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import Foundation
import FirebaseFirestoreSwift

struct Activity: Identifiable, Decodable, Encodable {
    @DocumentID var docID : String?
    var id = UUID()
    var name : String
    var date : Date
    var start : Date?
    var end : Date?
    var distance : Double?
    var repetitions : Double?
//    var officeWorkout : Bool
    var repeating : Bool
    var category : Category
    
    func formattedDate(date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        guard let date = date else {return ""}
        return String(date.formatted(date: .omitted, time: .shortened))
    }
}
