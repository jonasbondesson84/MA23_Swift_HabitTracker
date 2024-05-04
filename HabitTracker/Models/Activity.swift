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
    var started: Int = 0
    var start : Date?
    var end : Date?
    var distance : Double?
    var repetitions : Double?
//    var officeWorkout : Bool
    var repeating : Bool
    var category : Category
//    var registeredActivities = [ActivityEntry]()
    var streak : Int = 0
    var lastEntry : ActivityEntry
    var todaysEntry: ActivityEntry
    var doneDate: Date?
    
//    var entries = [ActivityEntry]()
    
    func formattedDate(date: Date?) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        guard let date = date else {return ""}
        return String(date.formatted(date: .omitted, time: .shortened))
    }
}

struct ActivityEntry: Identifiable, Decodable, Encodable, Hashable {
    @DocumentID var docID: String?
    var id = UUID()
    var date : Date?
    var start : Date?
    var end : Date?
    var totalTime: Int?
    var actitivyID: String?
    
    func calculateTimeForActivityEntry() -> Int {
        guard let start = start else {return 0}
         let end = Date.now
        return Int(end.timeIntervalSince(start))
    }
}

struct ActivityStats: Identifiable, Decodable, Encodable, Hashable {
    var id = UUID()
    var name : String
    var entries : [ActivityEntry]
}
extension ActivityStats {
    static let emptyStats = ActivityStats(name: "Running", entries: [ActivityEntry]())
}
