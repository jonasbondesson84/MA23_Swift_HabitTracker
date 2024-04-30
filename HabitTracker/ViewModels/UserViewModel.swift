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
    @Published var user = User(name: "Jonas", imageUrl: nil, streak: 0)  //Kolla med david varför den inte uppdateras i listan?
    @Published var categories = [Category]()
    @Published var todaysActivities = [Activity]()
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
    
    func getTodaysActivities() {
        self.todaysActivities.removeAll()
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        
        guard let userID = auth.currentUser?.uid else {return}
        
        db.collection("users").document(userID).collection(ACTIVITY)
            .whereField("date", isLessThan: end)
            .whereField("repeating", isEqualTo: true)
            .addSnapshotListener() {snapshot, error in
                guard let snapshot = snapshot else {return}
                if let error = error {
                    print("error loading todays activities: \(error)")
                } else {
                    self.todaysActivities.removeAll()
                    for document in snapshot.documents {
                        do {
                            let activity = try document.data(as: Activity.self)
                            self.todaysActivities.append(activity)
                            
                        } catch {
                            print("Error reading from db")
                        }
                    }
                }
                
            }
        db.collection("users").document(userID).collection(ACTIVITY)
                    .whereField("date", isGreaterThan: start)
                    .whereField("date", isLessThan: end)
                    .whereField("repeating", isEqualTo: false)
                    .addSnapshotListener() {snapshot, error in
                        guard let snapshot = snapshot else {return}
                        if let error = error {
                            print("error loading todays activities: \(error)")
                        } else {
                           
                            for document in snapshot.documents {
                                do {
                                    print(document.documentID)
                                    let activity = try document.data(as: Activity.self)
                                    self.todaysActivities.append(activity)
        
                                } catch {
                                    print("Error reading from db")
                                }
                            }
                        }
                    }
        
//        self.user.todaysActivities.removeAll()
//        
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.year, .month, .day], from: Date())
//        let start = calendar.date(from: components)!
//        let end = calendar.date(byAdding: .day, value: 1, to: start)!
//        
//        guard let userID = auth.currentUser?.uid else {return}
//        
//        db.collection("users").document(userID).collection(ACTIVITY)
//            .whereField("date", isGreaterThan: start)
//            .whereField("date", isLessThan: end)
//            .addSnapshotListener() {snapshot, error in
//                guard let snapshot = snapshot else {return}
//                if let error = error {
//                    print("error loading todays activities: \(error)")
//                } else {
//                    self.user.todaysActivities.removeAll()
//                    for document in snapshot.documents {
//                        do {
//                            let activity = try document.data(as: Activity.self)
//                            self.user.todaysActivities.append(activity)
//                            
//                        } catch {
//                            print("Error reading from db")
//                        }
//                    }
//                }
//            }
    }
    
    func startActivityEntry(activity: Activity) {
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
                        if Calendar.current.isDateInToday(entry.date) {
                            print("add ending")
                            //Lägga till slut
                            if let docID = entry.docID {
                                self.updateEntry(userID: userID, activityID: activityID, docID: docID)
                                
                                return
                            }
                        }
                    }
                    try self.db.collection("users").document(userID).collection(self.ACTIVITY).document(activityID).collection(self.ACTIVITY_ENTRY).addDocument(from: ActivityEntry(date: Date.now, start: Date.now))
//                    let activity = try snapshot.data(as: Activity.self)
//                    let activities = ActivityEntry()
//                    for registeredActivity in activity.registeredActivities {
//                        if Calendar.current.isDateInToday(registeredActivity.date) {
//                            print("it is today")
//                            let entry = ActivityEntry()
//                        } else {
//                            print("\(registeredActivity.date)")
//                        }
//                    }
                } catch {
                    print("Error loading from database")
                }
            }
        }
    }
    
    func updateEntry(userID: String, activityID: String, docID: String) {
        db.collection("users").document(userID).collection(ACTIVITY).document(activityID).collection(ACTIVITY_ENTRY).document(docID).updateData(["end": Date.now])
    }
    
    func startActivity(activity: Activity) {
        guard let userID = auth.currentUser?.uid else {return}
        guard let docID = activity.docID else {return}
        db.collection("users").document(userID).collection(ACTIVITY).document(docID).updateData(["start": Date()])
    }
    
    func stopActivity(activity: Activity) {
        guard let userID = auth.currentUser?.uid else {return}
        guard let docID = activity.docID else {return}
        db.collection("users").document(userID).collection(ACTIVITY).document(docID).updateData(["end": Date()])
    }
    
    

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
//        let strech = OfficeWorkout(name: "Strech", repeatTimeHours: 1.30)
//        let pushup = OfficeWorkout(name: "Push ups", repeatTimeHours: 2.0)
//
//        user.officeWorkOut.append(strech)
//        user.officeWorkOut.append(pushup)
//
//        let running = Activity(name: "Running", date: Date(), start: Date(), end: nil, officeWorkout: false, repeating: false, category: Category(name: "Runnning", image: "figure.run"))
//        activities.append(running)
//        let swimming = Activity(name: "Swimming", date: Date(), start: Date(), end: nil, officeWorkout: false, repeating: false, category: Category(name: "Swimming", image: "figure.pool.swim"))
//        activities.append(swimming)
//        user.todaysActivities.append(running)
//        user.todaysActivities.append(swimming)
//
        
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
