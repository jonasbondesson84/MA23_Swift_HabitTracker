//
//  User.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import Foundation

class User : ObservableObject, Decodable {
    var uid : String?
    var name: String
//    var sex: Int //0 = Female, 1 = Male, 2 = Other
    var imageUrl : String?
//    var streak : Int
    var badges = [Badge]()
//    @Published var activities = [Activity]()
//    @Published var todaysActivities = [Activity]()
//    @Published var officeWorkOut = [OfficeWorkout]()
    var totalStreak: Int
    var lastDateForStreak : Date?
    
    init(name: String, imageUrl: String?, badges: [Badge] = [Badge]()) {
        self.name = name
        self.imageUrl = imageUrl
//        self.streak = streak
        self.badges = badges
        self.totalStreak = 0
    }
    
    func getTarget() -> Int{
        switch self.totalStreak {
        case 0...5 :
            return 5
        case 6...10 :
            return 10
        case 11...30 :
            return 30
        default:
            return 100
        }
    }
    
    
}
