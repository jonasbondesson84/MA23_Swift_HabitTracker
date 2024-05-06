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
    @Published var showStart: Bool = false
    @Published var showEnd: Bool = false
    @Published var showDone: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    var timer: Timer?
    @Published var startedActivityID : String?
    @Published var badges = [Badge]()
    @Published var showNewBadge: Bool = false
    @Published var activityStats = [ActivityStats]()
        
    
    @Published var activities = [Activity]()
    @Published var officeWorkouts = [OfficeWorkout]()
    @Published var user = User(name: "Jonas", imageUrl: nil)  //Kolla med david varför den inte uppdateras i listan?
    @Published var categories = [Category]()
    @Published var todaysActivities = [Activity]()
    @Published var streak = 0
    let db = Firestore.firestore()
    let auth = Auth.auth()
    let ACTIVITY = "activity"
    let WORKOUT = "officeWorkout"
    let ACTIVITY_ENTRY = "entry"
    let BADGES = "badges"
    
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
        startListenBadges(userUID: userUID)
        startListenToUserDetails(userUID: userUID)
//        getTodaysActivities()
    }
    func startListenBadges(userUID : String) {
//        let db = Firestore.firestore()
        db.collection("users").document(userUID).collection(BADGES).addSnapshotListener() {snapshot, error in
        
            guard let snapshot = snapshot else {return}
            
            if let error = error {
                print("error loading office workout: \(error)")
            } else {
                self.badges.removeAll()
                for document in snapshot.documents {
                    do {
                        let badge = try document.data(as: Badge.self)
                        self.badges.append(badge)
                        self.badges.sort(by: {$0.streak < $1.streak})
                        
                    } catch {
                        print("Error reading from db")
                    }
                    
                }
                
                
            }
        }
    }
    func startListenOfficeWorkout(userUID : String) {
//        let db = Firestore.firestore()
        db.collection("users").document(userUID).collection(WORKOUT).addSnapshotListener() {snapshot, error in
        
            guard let snapshot = snapshot else {return}
            
            if let error = error {
                print("error loading office workout: \(error)")
            } else {
                self.officeWorkouts.removeAll()
                for document in snapshot.documents {
                    
                    do {
                        let workout = try document.data(as: OfficeWorkout.self)
                        self.officeWorkouts.append(workout)
//                        print("\(self.officeWorkouts.count)")
                        
                    } catch {
                        print("Error reading from db")
                    }
                }
                self.setRemindersForOfficeHours()
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
                        self.activities.append(activity)
                        //------------------------------------------
//                        self.categories.removeAll()
                    } catch {
                        print("Error reading from db")
                    }
                }
                self.getActivityStats()
            }
        }
    }
    func startListenToUserDetails(userUID: String) {
        
        db.collection("users").addSnapshotListener() {snapshot, error in
            
            guard let snapshot = snapshot else {return}
            
            if let error = error {
                print("error loading activities: \(error)")
            } else {
                for document in snapshot.documents {
                    if document.documentID == userUID {
                        do {
                            self.user = try document.data(as: User.self)
                        } catch {
                            print("error loading user")
                        }
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
    
    func updateActivity(activity: Activity) {
        guard let userID = auth.currentUser?.uid else {return}
        if let docID = activity.docID {
            db.collection("users").document(userID).collection(ACTIVITY).document(docID).updateData([
                "name" : activity.name,
                "repeating" : activity.repeating,
                "category.name" : activity.category.name,
                "category.image" : activity.category.image,
                "date" : activity.date
                
            ])
            
        }
    }
    
    func deleteActivity(offset: IndexSet) {
        guard let userID = auth.currentUser?.uid else {return}
        for index in offset {
            print("\(index)")
            let activity = activities[index]
            if let docID = activity.docID {
                db.collection("users").document(userID).collection(ACTIVITY).document(docID).delete()
            }
        }
        print("Delete")
    }
    
    func saveOfficeWorkoutToFireStore(workout: OfficeWorkout) {
        guard let userID = self.user.uid else {return}
        do {
            try db.collection("users").document(userID).collection(WORKOUT).addDocument(from: workout)
        } catch {
            print("Error wrinting to Firestore")
        }
    }
    func updateOfficeWorkout(workout: OfficeWorkout) {
        guard let userID = auth.currentUser?.uid else {return}
        if let docID = workout.docID {
            db.collection("users").document(userID).collection(WORKOUT).document(docID).updateData([
                "name" : workout.name,
                "active" : workout.active,
                "repeatTimeHours" : workout.repeatTimeHours
            ])
            
        }
    }
    
    func deleteOfficeWorkout(offset: IndexSet) {
        guard let userID = auth.currentUser?.uid else {return}
        for index in offset {
            print("\(index)")
            let workout = officeWorkouts[index]
            if let docID = workout.docID {
                db.collection("users").document(userID).collection(WORKOUT).document(docID).delete()
            }
        }
        print("Delete")
    }
    
    func startActivityEntry(activity: Activity) {
        guard let userID = auth.currentUser?.uid else {return}
        guard let activityID = activity.docID else {return}
        self.startTimer()
        startedActivityID = activity.docID
        do {
            try self.db.collection("users").document(userID).collection(self.ACTIVITY).document(activityID).collection(self.ACTIVITY_ENTRY).addDocument(from: ActivityEntry(date: Date.now, start: Date.now, actitivyID: activityID))
//            self.updateActivityWith(lastEntry: activity)
            self.db.collection("users").document(userID).collection(self.ACTIVITY).document(activityID).updateData(["todaysEntry.date": Date.now, "todaysEntry.start" : Date.now])
        } catch {
            print("Error writing start activity")
        }
    }
    
    func stopActivityEntry(activity: Activity) {
        guard let userID = auth.currentUser?.uid else {return}
        guard let activityID = activity.docID else {return}
        self.stopTimer()
        startedActivityID = nil
        
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
                                    self.db.collection("users").document(userID).collection(self.ACTIVITY).document(activityID).collection(self.ACTIVITY_ENTRY).document(docID).updateData(["end": Date.now, "totalTime": entry.calculateTimeForActivityEntry()]) {error in
                                        if let error = error {
                                            print("Error writing to database: \(error)")
                                        } else {
                                            self.db.collection("users").document(userID).collection(self.ACTIVITY).document(activityID).updateData(["todaysEntry.date": Date.now, "todaysEntry.end" : Date.now]) { error in
                                                if let error = error {
                                                    print("Error writing to database: \(error)")
                                                } else {
                                                    
                                                    self.addToStreak(activity: activity)
                                                    self.addToTotalStreak()
                                                    
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
        getBadgeFor(activity: activity, streak: streak)
        
        db.collection("users").document(user.uid).collection(ACTIVITY).document(docID).updateData(["streak": streak, "lastEntry.date": lastEntryDate, "lastEntry.start": lastEntyStart, "lastEntry.end": lastEntryEnd, "todaysEntry.date": FieldValue.delete(), "todaysEntry.start": FieldValue.delete(), "todaysEntry.end": FieldValue.delete(), "doneDate": Date.now])
    }
    
    func addToTotalStreak() {
        print("here now")
        guard let userID = auth.currentUser?.uid else {return}
        if let lastDate = user.lastDateForStreak {
            if Calendar.current.isDateInYesterday(lastDate) {
                let totalStreak = user.totalStreak + 1
                print("\(totalStreak)")
                db.collection("users").document(userID).updateData([
                    "totalStreak" : totalStreak
                ])
            }
        }
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
    
    func showTimerAsTime(seconds: Double) ->String {
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
        
        let formattedDuration = formatDuration(Int(seconds))
        
        return formattedDuration
    }
    
    func updateTodaysActivities() {
        guard let userSignedIn = auth.currentUser else {return}
        let userID = userSignedIn.uid
        
        db.collection("users").document(userID).collection(ACTIVITY).getDocuments() {snapshot, error in
            
            guard let snapshot = snapshot else {return}
            
            if let error = error {
                print("error loading activities: \(error)")
            } else {
//                self.activities.removeAll()
                self.todaysActivities.removeAll()
                for document in snapshot.documents {
                    do {
                        print("get data.")
                        let activity = try document.data(as: Activity.self)
//                        self.user.activities.append(activity)
                        if (activity.repeating && activity.date.timeIntervalSinceNow.sign == .minus) || Calendar.current.isDateInToday(activity.date) {
                            self.todaysActivities.append(activity)
                            
                        }
//                        self.activities.append(activity) //------------------------------------------
//                        self.categories.removeAll()
                    } catch {
                        print("Error reading from db activity")
                    }
                }
            }
        }
    }
    
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.elapsedTime += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
    }
    
    func setRemindersForOfficeHours() {
        let center = UNUserNotificationCenter.current()
        
        center.removeAllPendingNotificationRequests()
        
        for workout in self.officeWorkouts {
            if workout.active {
                let content = UNMutableNotificationContent()
                content.title = "Office Workout Reminder"
                content.body = "It's time for your \(workout.name)!"
                content.sound = UNNotificationSound.default
                
                var dateComponent = DateComponents()
                
                for repeating in 0...8 {
                    let startHour = 8
                    let endHour = 16
                    let repeatTime = startHour + (workout.repeatTimeHours * repeating)
                    if repeatTime < endHour && repeatTime > startHour{
                        dateComponent.hour = repeatTime
                        dateComponent.minute = 0
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: true)
                        
                        //                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//                        print("\(trigger)")
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        center.add(request)
                    }
                }
                
//                center.getPendingNotificationRequests { requests in
//                    for request in requests {
//                        print("Notification Identifier: \(request.identifier)")
//                        print("Notification Content: \(request.content)")
//                        print("Notification Trigger: \(request.trigger)")
//                        print("-----------------------------------")
//                    }
//                }
                
            }
        }
    }
    
    func updateWorkoutActiv(workout: OfficeWorkout, active: Bool) {
        guard let userID = auth.currentUser?.uid else {return}
        guard let docID = workout.docID else {return}
        db.collection("users").document(userID).collection(WORKOUT).document(docID).updateData(["active": active]) { error in
            if let error = error {
                print("Error updating workout: \(error)")
            } else {
                self.setRemindersForOfficeHours()
            }
        }
    }
    
    func getBadgeFor(activity: Activity, streak: Int) {
        
        if streak == 5 {
            let newBadge = Badge(name: activity.name, streak: streak, category: activity.category.name, image: "label-5028260_640")
            updateDbWith(newBadge: newBadge)
        } else if streak == 10 {
            let newBadge = Badge(name: activity.name, streak: streak, category: activity.category.name, image: "label-5028260_640")
            updateDbWith(newBadge: newBadge)
        }
        else if streak == 30 {
            let newBadge = Badge(name: activity.name, streak: streak, category: activity.category.name, image: "label-5028260_640")
            updateDbWith(newBadge: newBadge)
        }
        else if streak == 100 {
            let newBadge = Badge(name: activity.name, streak: streak, category: activity.category.name, image: "label-5028260_640")
            updateDbWith(newBadge: newBadge)
        }
        
    }
    
    func updateDbWith(newBadge: Badge) {
        
        guard let userID = auth.currentUser?.uid else {return}
        self.badges.append(newBadge)
        showNewBadge = true
        
        do {
            try db.collection("users").document(userID).collection(BADGES).addDocument(from: newBadge)
            print("Saved Badge")
        } catch {
            print("Error writing to Firestore")
        }
//        db.collection("users").document(userID).collection(BADGES).addDocument(from: newBadge)
    }

//    func getAllActivityEntries() {
//        guard let userID = auth.currentUser?.uid else {return}
//        
//        for activity in activities {
//            if let docID = activity.docID {
//                do {
//                    db.collection("users").document(userID).collection(ACTIVITY).document(docID).collection(ACTIVITY_ENTRY).getDocuments() {snapshot, error in
//                        guard let snapshot = snapshot else {return}
//                        
//                        for document in snapshot.documents {
//                            let entry = try document.data(as: ActivityEntry.self)
//                            
//                        }
//                        
//                    }
//                    
//                } catch {
//                    print("Error")
//                }
//            }
//        }
//    }
    
//    func getActivityEntries(docID: String)-> [ActivityEntry] {
//        
//        var list = [ActivityEntry]()
//        guard let userID = auth.currentUser?.uid else {return [ActivityEntry]()}
//        
//        db.collection("users").document(userID).collection(ACTIVITY).document(docID).collection(ACTIVITY_ENTRY).getDocuments() { snapshot, error in
//            
//            guard let snapshot = snapshot else {return}
//            do {
//                if let error = error {
//                    print("error getting activityEntry")
//                } else {
//                    for document in snapshot.documents {
//                        let entry = try document.data(as: ActivityEntry.self)
//                        list.append(entry)
//                    }
//                    
//                }
//                return
//            } catch {
//                print("Error")
//            }
//            
//        }
//        return list
//    }
      
//    func getActivityEntries(docID: String, completion: @escaping ([ActivityEntry]) -> Void) {
//        var list = [ActivityEntry]()
//        guard let userID = auth.currentUser?.uid else {
//            completion([])
//            return
//        }
//        
//        db.collection("users").document(userID).collection(ACTIVITY).document(docID).collection(ACTIVITY_ENTRY).getDocuments() { snapshot, error in
//            guard let snapshot = snapshot else {
//                completion([])
//                return
//            }
//            
//            do {
//                if let error = error {
//                    print("Error getting activityEntry: \(error)")
//                    completion([])
//                } else {
//                    for document in snapshot.documents {
//                        let entry = try document.data(as: ActivityEntry.self)
//                        list.append(entry)
//                        
//                    }
//                    completion(list)
//                }
//            } catch {
//                print("Error parsing data: \(error)")
//                completion([])
//            }
//        }
//    }
    
    func getActivityStats() {
        guard let userID = auth.currentUser?.uid else {return}
        activityStats.removeAll()
        for activity in activities {
            var list = [ActivityEntry]()
            if let docID = activity.docID {
                db.collection("users").document(userID).collection(ACTIVITY).document(docID).collection(ACTIVITY_ENTRY).getDocuments() { snapshot, error in
                
                            guard let snapshot = snapshot else {return}
                            do {
                                if let error = error {
                                    print("error getting activityEntry \(error)")
                                } else {
                                    for document in snapshot.documents {
                                        let entry = try document.data(as: ActivityEntry.self)
                                        list.append(entry)
                                    }
                                    let stats = ActivityStats(name: activity.name, entries: list)
                                    self.activityStats.append(stats)
                                    print("\(self.activityStats.count) \(stats.name)")
                
                                }
                                
                            } catch {
                                print("Error")
                            }
                
                        }
            }
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

        
//        var badge = Badge(name: "5 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
//        badge = Badge(name: "10 days", category: "Running", image: "badge_blue")
//        user.badges.append(badge)
        
    }
    
    
}
