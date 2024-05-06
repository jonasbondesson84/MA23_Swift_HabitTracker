//
//  ActivityView.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var userData: UserViewModel
//    @State var showAddActivity = false
    @State var showAddOfficeWorkout = false
//    @State var edit: Bool = false
    
    
    
    
    var body: some View {
        ZStack {
            AppColors.backgroundColor
                .ignoresSafeArea()
            VStack {
                MyActivityList()
                    .padding(.bottom, 30)
                MyOfficeWorkoutList()
                    .padding(.bottom, 30)
                
            }
        
        }
        
    }
}

struct AddActivitySheet: View {
    @Binding var activity : Activity?
    @Binding var edit: Bool
//    @Binding var showSheet: Bool
    @State var name: String = ""
    @State var date: Date = .now
    @State var category : Category = .emptyCategory //= Category(name: "Running", image: "figure.run")
    @State var selectedCategory = 0
    @State var recurrent : Bool = true
    @State var recurrentDays: Int = 1
    
    @EnvironmentObject var userData : UserViewModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.sheetBackgroundColor
                .ignoresSafeArea()
            VStack {
                Text("Add activity")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                Form {
                    LabeledContent("Activity name") {
                        TextField("", text: $name)
                    }
                    LabeledContent("Date/Time") {
                        DatePicker("", selection: $date)
                    }
                    LabeledContent("Category") {
                        Picker("", selection: $category) {
                            ForEach(userData.categories) { category in
                                Text("\(category.name)").tag(category as Category)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    LabeledContent("Recurrent") {
                        Toggle(isOn: $recurrent) {
                            
                        }
                    }
                    LabeledContent("Recurrent days") {
                        Stepper(value: $recurrentDays, in :1...7) {
                            Text("\(recurrentDays)")
                        }
                    }
                    .opacity(recurrent ? 1: 0)
                    HStack {
                        
                        Button (action: {
                            
//                            let thisCatagory = userData.categories[selectedCategory]
                            if edit {
                                if let activity = activity {
                                    let updatedActivity = Activity(docID: activity.docID, name: name, date: date, repeating: recurrent, category: category, lastEntry: ActivityEntry(), todaysEntry: ActivityEntry())
                                    userData.updateActivity(activity: updatedActivity)
                                }
                            } else {
                                
                                let newActivity = Activity(name: name, date: date, repeating: recurrent, category: category, lastEntry: ActivityEntry(), todaysEntry: ActivityEntry())
                                userData.saveActivityToFireStore(activity: newActivity)
                            }
                            userData.setShowSheet(showSheet: false)
                            
                        }, label: {
                            Text(edit ? "Update" : "Save")
                        })
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Spacer()
                        
                        Button (action: {
                            print("cancel")
                            userData.setShowSheet(showSheet: false)
                        }, label: {
                            Text("Cancel")
                        })
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .onAppear() {
            print("Edit: \(edit)")
            if edit {
                
                if let activity = activity {
                    name = activity.name
                    date = activity.date
                    category = activity.category
                    recurrent = activity.repeating
                }
            } else {
                name = ""
                date = Date.now
                category = .emptyCategory
                recurrent = true
            }
            
        }
    }
}

struct AddOfficeWorkoutSheet: View {
    @Binding var workout : OfficeWorkout?
    @Binding var edit: Bool
    
//    @Binding var showsheet: Bool
    @EnvironmentObject var userData : UserViewModel
    
    @State var name: String = ""
    @State var repeatTimeHours: Int = 1
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.sheetBackgroundColor
                .ignoresSafeArea()
            VStack {
                Text("Add Office Workout")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .padding(.top, 10)
                Form {
                    LabeledContent("Workout name:") {
                        TextField("", text: $name)
                    }
                    LabeledContent("Repeat every: \(repeatTimeHours) hour") {
                        Stepper("", value: $repeatTimeHours, in: 1...8, step: 1)
                    }
                    
                    HStack {
                        Button {
                            
                            
                            if edit {
                                if let workout = workout {
                                    let newWorkout = OfficeWorkout(docID: workout.docID, name: name, repeatTimeHours: repeatTimeHours)
                                    userData.updateOfficeWorkout(workout: newWorkout)
                                }
                                
                            } else {
                                let newWorkout = OfficeWorkout(name: name, repeatTimeHours: repeatTimeHours)
                                userData.saveOfficeWorkoutToFireStore(workout: newWorkout)
                            }
                            
                            userData.setShowSheet(showSheet: false)
                            
                        } label: {
                            Text("Save")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        Spacer()
                        Button {
                            userData.setShowSheet(showSheet: false)
                        } label: {
                            Text("Cancel")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .scrollContentBackground(.hidden)
                .onAppear() {
                    if edit {
                        if let workout = workout {
                            name = workout.name
                            repeatTimeHours = workout.repeatTimeHours
                            
                        } else {
                            name = ""
                            repeatTimeHours = 1
                        }
                        print("edit")
                    }
                }
            }
        }
    }
}

struct MyOfficeWorkoutList: View {
    @EnvironmentObject var userData: UserViewModel
    @State var showSheet: Bool = false
    @State var edit: Bool = false
    @State var selectedWorkout : OfficeWorkout? = nil
    @State var index : IndexSet?
    @State var showWarning = false
    
    
    var body: some View {
        Text("My Office Workouts")
            .foregroundColor(.white)
            .font(.system(size: 12))
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity,alignment: .leading)
            .padding(.leading, 30)
            .fontWeight(.bold)
        
        List {
            
            ForEach (userData.officeWorkouts) {officeWorkOut in
                
                    HStack {
                        Text(officeWorkOut.name)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: officeWorkOut.active ? "star.fill": "star")
                            .foregroundColor(officeWorkOut.active ? .yellow: .white)
                            .onTapGesture {
                                userData.updateWorkoutActiv(workout: officeWorkOut, active: !officeWorkOut.active)
                            }
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                        
                    }
                    .onTapGesture {
                        selectedWorkout = officeWorkOut
                        edit = true
                        userData.setShowSheet(showSheet: true)
                    }
                }
            .onDelete(perform: { indexSet in
                index = indexSet
                showWarning = true
                
            })
            
            
            .padding(.vertical, 2)
            .listRowInsets(.init())
            .listRowBackground(AppColors.backgroundColor)
            
        }
        .sheet(isPresented: $userData.showSheet, content: {
            if userData.loggedIn {
                AddOfficeWorkoutSheet(workout: $selectedWorkout, edit: $edit)
                    .presentationBackground(.background)
                    .presentationDetents([.medium])
            } else {
                loginScreen()
                    .presentationBackground(.background)
                    .presentationDetents([.medium])
            }
//
        })
        .confirmationDialog("Do you want to delete this activity?", isPresented: $showWarning) {
            Button("Delete this activity?", role: .destructive) {
                index != nil ? userData.deleteOfficeWorkout(offset: index!) : print("didnt delete")
            }
        } message: {
            Text("You cannot undo this action")
          }
        .padding(.horizontal, 40)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        
        
        
        Button(action: {
            selectedWorkout = nil
            edit = false
            userData.setShowSheet(showSheet: true)
//            userData.saveOfficeWorkoutToFireStore(workout: OfficeWorkout(name: "Strech", repeatTimeHours: 1.5))

        }, label: {
            Label("Add Office Workout", systemImage: "plus")
        })
        .buttonStyle(AddButton())
        .padding(.horizontal, 40)
    }
    
}

struct MyActivityList: View {
    @EnvironmentObject var userData: UserViewModel
    @State var showSheet: Bool = false
    @State var edit: Bool = false
    @State var selectedActivity : Activity? = nil
    @State var showWarning = false
    @State var index : IndexSet?
    
    
    var body: some View {
        Text("My Activities")
            .foregroundColor(.white)
            .font(.system(size: 12))
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity,alignment: .leading)
            .padding(.leading, 30)
            .fontWeight(.bold)
        
        List {
            ForEach (userData.activities) { activity in
                HStack {
                    Text(activity.name)
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                }
                .onTapGesture {
                    selectedActivity = activity
                    
                    edit = true
                    userData.setShowSheet(showSheet: true)
                }
            }
            .onDelete(perform: { indexSet in
                index = indexSet
                showWarning = true
                
            })
            .padding(.vertical, 2)
            .listRowInsets(.init())
            .listRowBackground(AppColors.backgroundColor)
            
        }
        .listStyle(.plain)
        .padding(.horizontal, 40)
        .scrollContentBackground(.hidden)
        .sheet(isPresented: $showSheet, content: {
            if userData.loggedIn {
                AddActivitySheet(activity: $selectedActivity, edit: $edit)
                    .presentationBackground(.background)
                    .presentationDetents([.medium])
                
            } else {
                loginScreen()
                    .presentationBackground(.background)
                    .presentationDetents([.medium])
            }
        })
        .confirmationDialog("Do you want to delete this activity?", isPresented: $showWarning) {
            Button("Delete this activity?", role: .destructive) {
                index != nil ? userData.deleteActivity(offset: index!) : print("didnt delete")
            }
        } message: {
            Text("You cannot undo this action")
          }
        
        Button(action: {
            selectedActivity = nil
            edit = false
            userData.setShowSheet(showSheet: true)

        }, label: {
            Label("Add activity", systemImage: "plus")
        })
        .buttonStyle(AddButton())
        .padding(.horizontal, 40)
        
    }
        
}



struct AddButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
        
            .frame(maxWidth: .infinity)
            
            .frame(height: 40)
            
            .background(AppColors.buttonColor)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ActivityView()
        .environmentObject(UserViewModel())
}





struct ActivitiesView: View {
    @EnvironmentObject var user: UserViewModel
    
    var body: some View {
        Text("My Activities")
            .foregroundColor(.white)
            .font(.system(size: 12))
            .fontDesign(.rounded)
            .frame(maxWidth: .infinity,alignment: .leading)
            .padding(.leading, 30)
            .fontWeight(.bold)
        List {
            ForEach (user.activities) { activity in
                Text(activity.name)
                    .foregroundColor(.white)
            }
            .padding(.vertical, 2)
            .listRowInsets(.init())
            .listRowBackground(AppColors.backgroundColor)
        }
        .padding(.horizontal, 40)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        Button(action: {
            
        }, label: {
            Label("Add activity", systemImage: "plus.app")
        })
        .buttonStyle(AddButton())
        
    }
    

}

struct loginScreen : View {
    @EnvironmentObject var userData : UserViewModel
    @State var email : String = ""
    @State var password : String = ""
    @State var name : String = ""
    var body: some View {
        ZStack {
            AppColors.backgroundColor
            VStack {
                TextField("Email", text: $email)
                    .padding(.horizontal, 50)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(20.0)
                SecureField("Password", text: $password)
                    .padding(.horizontal, 50)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(20.0)
                TextField("Name", text: $name)
                    .padding(.horizontal, 50)
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(20.0)
                    .opacity(userData.newAccount ? 1.0 : 0.0)
                Button(userData.newAccount ? "Create account" : "Sign In") {
                    if userData.newAccount {
                        userData.createAccount(email: email, password: password, name: name)
                    } else {
                        userData.signIn(email: email, password: password)
                    }
                }
            }
        }
    }
}
