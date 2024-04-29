//
//  ActivityView.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import SwiftUI

struct ActivityView: View {
    @EnvironmentObject var userData: UserViewModel
    @State var showAddActivity = false
    @State var showAddOfficeWorkout = false
    
    
    var body: some View {
        ZStack {
            AppColors.backgroundColor
                .ignoresSafeArea()
            VStack {
                MyActivityList(showSheet: $showAddActivity)
                    .padding(.bottom, 30)
                MyOfficeWorkoutList(showSheet: $showAddOfficeWorkout)
                    .padding(.bottom, 30)
            }
        
        }
        .sheet(isPresented: $showAddActivity, content: {
            AddActivitySheet(showSheet: $showAddActivity)
                .presentationBackground(.background)
                .presentationDetents([.medium])
        }
        )
        .sheet(isPresented: $showAddOfficeWorkout, content: {
            AddOfficeWorkoutSheet(showsheet: $showAddOfficeWorkout)
                .presentationBackground(.background)
                .presentationDetents([.medium])
        })
    }
}



struct AddActivitySheet: View {
    @Binding var showSheet: Bool
    @State var name: String = ""
    @State var date: Date = .now
//    @State var category : CategoryEnum = .category(Category(name: "Running", image: "figure.run"))
    @State var category : Category = Category(name: "", image: "")
    @State var recurrent : Bool = false
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
                                Text("\(category.name)")
                            }
//                            ForEach(CategoryEnum.allCategories, id: \.self) { category in
//                                                if case let .category(categoryData) = category {
//                                                    Text(categoryData.name).tag(category)
//                                                }
//                                            }
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
                        Button {
                            
                            let newActivity = Activity(name: name, date: date, repeating: recurrent, category: category)
                                userData.saveActivityToFireStore(activity: newActivity)
                                showSheet = false
                            
                        } label: {
                            Text("Save")
                        }
                        Spacer()
                        Button {
                            showSheet = false
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .onAppear() {
            userData.createCategories()
//            category = userData.categories.first
        }
    }
}

struct AddOfficeWorkoutSheet: View {
    @Binding var showsheet: Bool
    @EnvironmentObject var userData : UserViewModel
    
    @State var name: String = ""
    @State var repeatWorkout: Double = 1.0
    
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
                    LabeledContent("Repeat every: \(repeatWorkout, specifier: "%.1f") hour") {
                        Stepper("", value: $repeatWorkout, in: 0.5...8, step: 0.5)
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
            
            ForEach (userData.user.officeWorkOut) {officeWorkOut in
                HStack {
                    Text(officeWorkOut.name)
                        .foregroundColor(.white)
                    Spacer()
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
    @Binding var showSheet: Bool
    
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
            }
            .padding(.vertical, 2)
            .listRowInsets(.init())
            .listRowBackground(AppColors.backgroundColor)
        }
        .listStyle(.plain)
        .padding(.horizontal, 40)
        .scrollContentBackground(.hidden)
        
        Button(action: {

            showSheet = true
//            userData.saveActivityToFireStore(activity: Activity(name: "Running 5 km", date: .now,  repeating: true, category: Category(name: "Running", image: "figure.run")))

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
