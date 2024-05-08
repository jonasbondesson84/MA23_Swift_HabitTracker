//
//  User.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import Foundation
import FirebaseFirestoreSwift

class User : ObservableObject, Decodable, Encodable {
    @DocumentID var docIC : String?
    var uid : String?
    var name: String
    var imageUrl : String?
    var badges = [Badge]()
    var totalStreak: Int
    var lastDateForStreak : Date?
    
    init(name: String, imageUrl: String?, badges: [Badge] = [Badge](), lastDateForStreak: Date?) {
        self.name = name
        self.imageUrl = imageUrl
        self.badges = badges
        self.totalStreak = 0
        self.lastDateForStreak = lastDateForStreak
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
    
    func getArcForTotalStreak() -> Double {
        print("TotalStreak: \(Double(self.totalStreak))")
        print("getTarget: \(self.getTarget())")
        let arcNr = Double(self.totalStreak)/Double(self.getTarget())
        print("arc: \(arcNr)")
        return arcNr
    }

}
