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
                MyOfficeWorkoutList(showSheet: $showAddOfficeWorkout)
                    .padding(.bottom, 30)
            }
        
        }
        
        .sheet(isPresented: $showAddOfficeWorkout, content: {
            AddOfficeWorkoutSheet(showsheet: $showAddOfficeWorkout)
                .presentationBackground(.background)
                .presentationDetents([.medium])
        })
        
    }
}

struct AddActivitySheet: View {
    @Binding var activity : Activity?
    @Binding var edit: Bool
    @Binding var showSheet: Bool
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
                            print("save")
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
                                showSheet = false
                            
                        }, label: {
                            Text(edit ? "Update" : "Save")
                        })
                        .buttonStyle(BorderlessButtonStyle())
                        
                        Spacer()
                        
                        Button (action: {
                            print("cancel")
                            showSheet = false
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
    @Binding var showsheet: Bool
    @EnvironmentObject var userData : UserViewModel
    
    @State var name: String = ""
    @State var repeatWorkout: Int = 1
    
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
                    LabeledContent("Repeat every: \(repeatWorkout) hour") {
                        Stepper("", value: $repeatWorkout, in: 1...8, step: 1)
                    }
                    
                    HStack {
                        Button {
                            let newWorkout = OfficeWorkout(name: name, repeatTimeHours: repeatWorkout)
                            userData.saveOfficeWorkoutToFireStore(workout: newWorkout)
                            showsheet = false
                            
                        } label: {
                            Text("Save")
                        }
                        Spacer()
                        Button {
                            showsheet = false
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

struct MyOfficeWorkoutList: View {
    @EnvironmentObject var userData: UserViewModel
    @Binding var showSheet: Bool
    
    
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
                }
            
            
            .padding(.vertical, 2)
            .listRowInsets(.init())
            .listRowBackground(AppColors.backgroundColor)
            
        }
        .padding(.horizontal, 40)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        
        
        
        Button(action: {

            showSheet = true
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
                    showSheet = true
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
            AddActivitySheet(activity: $selectedActivity, edit: $edit, showSheet: $showSheet)
                .presentationBackground(.background)
                .presentationDetents([.medium])
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
            showSheet = true

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
