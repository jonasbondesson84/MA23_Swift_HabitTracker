//
//  UserViewModel.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

class UserViewModel: ObservableObject {
    
    @Published var activities = [Activity]()
    @Published var officeWorkout = [OfficeWorkout]()
    @Published var user = User(name: "Jonas", imageUrl: nil)  //Kolla med david varför den inte uppdateras i listan?
    @Published var categories = [Category]()
    @Published var todaysActivities = [Activity]()
    @Published var streak = 0
    let db = Firestore.firestore()
    let auth = Auth.auth()
    let ACTIVITY = "activity"
    let WORKOUT = "officeWorkout"
    let ACTIVITY_ENTRY = "entry"
    
    init() {

//        creatDummyData()
        createCategories()
    }
    
    func checkSignIn() {
        let auth = Auth.auth()
        if let user = auth.currentUser {
            self.user.uid = user.uid
            listenToFireBase(userUID: user.uid)
            
            print("Was signed in")
        } else {
            print("was not signed in")
            signIn()
        }
    }
    
    func signIn() {
        let auth = Auth.auth()
        auth.signInAnonymously { [self]result, error in
            if let error = error {
                print("error: \(error)")
            } else {
                print("success")
                guard let userSignedIn = auth.currentUser else {return}
                self.user.uid = userSignedIn.uid
                listenToFireBase(userUID: userSignedIn.uid)
            }
        }
    }
    
    func listenToFireBase(userUID: String) {
        startListenActivity(userUID: userUID)
        startListenOfficeWorkout(userUID: userUID)
//        getTodaysActivities()
    }
    
    func startListenOfficeWorkout(userUID : String) {
//        let db = Firestore.firestore()
        db.collection("users").document(userUID).collection(WORKOUT).addSnapshotListener() {snapshot, error in
        
            guard let snapshot = snapshot else {return}
            
            if let error = error {
                print("error loading office workout: \(error)")
            } else {
                self.officeWorkout.removeAll()
                for document in snapshot.documents {
                    do {
                        let workout = try document.data(as: OfficeWorkout.self)
                        self.officeWorkout.append(workout)
                        
                    } catch {
                        print("Error reading from db")
                    }
                }
            }
        }
    }
    
    func startListenActivity(userUID: String) {
//        let db = Firestore.firestore()
        
        db.collection("users").document(userUID).collection(ACTIVITY).addSnapshotListener() {snapshot, error in
            
            guard let snapshot = snapshot else {return}
            
            if let error = error {
                print("error loading activities: \(error)")
            } else {
                self.activities.removeAll()
                self.todaysActivities.removeAll()
                for document in snapshot.documents {
                    do {
                        let activity = try document.data(as: Activity.self)
//                        self.user.activities.append(activity)
                        if (activity.repeating && activity.date.timeIntervalSinceNow.sign == .minus) || Calendar.current.isDateInToday(activity.date) {
                            self.todaysActivities.append(activity)
                            
                        }
                        self.activities.append(activity) //------------------------------------------
//                        self.categories.removeAll()
                    } catch {
                        print("Error reading from db")
                    }
                }
            }
        }
    }
    
    
    
    func saveActivityToFireStore(activity: Activity) {
        guard let userID = self.user.uid else {return}
        do {
            try db.collection("users").document(userID).collection(ACTIVITY).addDocument(from: activity)
            print("Saved activity")
        } catch {
            print("Error writing to Firestore")
        }
    }
    
    func saveOfficeWorkoutToFireStore(workout: OfficeWorkout) {
        guard let userID = self.user.uid else {return}
        do {
            try db.collection("users").document(userID).collection(WORKOUT).addDocument(from: workout)
        } catch {
            print("Error wrinting to Firestore")
        }
    }
    
    func startActivityEntry(activity: Activity) {
        guard let userID = auth.currentUser?.uid else {return}
        guard let activityID = activity.docID else {return}
        do {
            try self.db.collection("users").document(userID).collection(self.ACTIVITY).document(activityID).collection(self.ACTIVITY_ENTRY).addDocument(from: ActivityEntry(date: Date.now, start: Date.now))
//            self.updateActivityWith(lastEntry: activity)
            self.db.collection("users").document(userID).collection(self.ACTIVITY).document(activityID).updateData(["todaysEntry.date": Date.now, "todaysEntry.start" : Date.now])
        } catch {
            print("Error writing start activity")
        }
    }
    
    func stopActivityEntry(activity: Activity) {
        guard let userID = auth.currentUser?.uid else {return}
        guard let activityID = activity.docID else {return}
        
        db.collection("users").document(userID).collection(ACTIVITY).document(activityID).collection(ACTIVITY_ENTRY).getDocuments() {snapshot, error in
            guard let snapshot = snapshot else {return}
            if let error = error {
                print("Error getting activity: \(error)")
            } else {
                do {
                    for document in snapshot.documents {
                        let entry = try document.data(as: ActivityEntry.self)
                        print(entry)
                        if let entryDate = entry.date {
                            if Calendar.current.isDateInToday(entryDate) {
                                if let docID = entry.docID {
                                    self.db.collection("users").document(userID).collection(self.ACTIVITY).document(activityID).collection(self.ACTIVITY_ENTRY).document(docID).updateData(["end": Date.now]) {error in
                                        if let error = error {
                                            print("Error writing to database: \(error)")
                                        } else {
                                            self.db.collection("users").document(userID).collection(self.ACTIVITY).document(activityID).updateData(["todaysEntry.date": Date.now, "todaysEntry.end" : Date.now]) { error in
                                                if let error = error {
                                                    print("Error writing to database: \(error)")
                                                } else {
                                                    self.addToStreak(activity: activity)
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    

                } catch {
                    print("Error loading from database")
                }
            }
        }
    }

    
    func addToStreak(activity: Activity) {
        @EnvironmentObject var userData: UserViewModel
        guard let userID = auth.currentUser?.uid else {return}
        if let activityID = activity.docID {
            db.collection("users").document(userID).collection(ACTIVITY).document(activityID).getDocument {(document, error) in
                if let document = document {
                    do {
                        let activity = try document.data(as: Activity.self)
                        if let lastEntryDate = activity.lastEntry.date {
                            if Calendar.current.isDateInYesterday(lastEntryDate) {
                                self.startNewStreak(activity: activity, newStreak: false)
                            }
                            else {
                                self.startNewStreak(activity: activity, newStreak: true)
                            }
                        } else {
                            self.startNewStreak(activity: activity, newStreak: true)
                        }
                    } catch {
                        print("Erroe")
                    }
                }
            }
        }
    }
    
    func startNewStreak(activity: Activity, newStreak: Bool) {
        guard let user = auth.currentUser else {return}
        guard let docID = activity.docID else {return}
        guard let lastEntryDate = activity.todaysEntry.date else {return}
        guard let lastEntyStart = activity.todaysEntry.start else {return}
        guard let lastEntryEnd = activity.todaysEntry.end else {return}
        var streak = 0
        if newStreak {
            streak = 1
        } else {
            streak = activity.streak + 1
        }
        
        db.collection("users").document(user.uid).collection(ACTIVITY).document(docID).updateData(["streak": streak, "lastEntry.date": lastEntryDate, "lastEntry.start": lastEntyStart, "lastEntry.end": lastEntryEnd, "todaysEntry.date": FieldValue.delete(), "todaysEntry.start": FieldValue.delete(), "todaysEntry.end": FieldValue.delete(), "doneDate": Date.now])
    }
    
    func calculateActivityTime(activity: Activity)-> String {
        guard let start = activity.lastEntry.start else {return "start error"}
        guard let end = activity.lastEntry.end else {return "end error"}
        
        
        
        
       let timeInSeconds = Int(end.timeIntervalSince(start))
       
        func formatDuration(_ durationInSeconds: Int) -> String {
           let (hours, secondsAfterHours) = divmod(durationInSeconds, 3600)
           let (minutes, seconds) = divmod(secondsAfterHours, 60)
           return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
        func divmod(_ numerator: Int, _ denominator: Int) -> (quotient: Int, remainder: Int) {
           let quotient = numerator / denominator
           let remainder = numerator % denominator
           return (quotient, remainder)
        }
        
        let formattedDuration = formatDuration(timeInSeconds)
        
        return formattedDuration
    }
    
    
    
//    func updateStreakData(activity: Activity) {
//        guard let user = auth.currentUser else {return}
//        guard let docID = activity.docID else {return}
//        guard let lastEntryDate = activity.todaysEntry.date else {return}
//        guard let lastEntyStart = activity.todaysEntry.start else {return}
//        guard let lastEntryEnd = activity.todaysEntry.end else {return}
//        
//        let streak = activity.streak + 1
//        db.collection("users").document(user.uid).collection(ACTIVITY).document(docID).updateData(["streak": streak, "lastEntry.date": lastEntryDate, "lastEntry.start": lastEntyStart, "lastEntry.end": lastEntryEnd])
//    }
    
    

    func createCategories() {
        categories.removeAll()
        let running = Category(name: "Runnning", image: "figure.run")
        categories.append(running)
        let swimming = Category(name: "Swimming", image: "figure.pool.swim")
        categories.append(swimming)
        let cycling = Category(name: "Cycling", image: "figure.outdoor.cycle")
        categories.append(cycling)
    }
    
    func creatDummyData() {

        
        var badge = Badge(name: "5 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
        user.badges.append(badge)
        
    }
    
    
}
