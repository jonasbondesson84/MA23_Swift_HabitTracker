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
    @Published var user = User(name: "Jonas", imageUrl: nil, streak: 0)  //Kolla med david varför den inte uppdateras i listan?
    @Published var categories = [Category]()
    let db = Firestore.firestore()
        let ACTIVITY = "activity"
        let WORKOUT = "officeWorkout"
    
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
    }
    
    func startListenOfficeWorkout(userUID : String) {
//        let db = Firestore.firestore()
        db.collection("users").document(userUID).collection(WORKOUT).addSnapshotListener() {snapshot, error in
        
            guard let snapshot = snapshot else {return}
            
            if let error = error {
                print("error loading office workout: \(error)")
            } else {
                self.user.officeWorkOut.removeAll()
                for document in snapshot.documents {
                    do {
                        let workout = try document.data(as: OfficeWorkout.self)
                        self.user.officeWorkOut.append(workout)
                        
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
                self.user.activities.removeAll()
                for document in snapshot.documents {
                    do {
                        let activity = try document.data(as: Activity.self)
                        self.user.activities.append(activity)
//                        self.activities.append(activity)
                        self.categories.removeAll()
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
