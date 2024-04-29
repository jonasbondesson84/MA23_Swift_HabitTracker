//
//  MyDayView.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import SwiftUI

struct MyDayView: View {
    
    @EnvironmentObject var userData : UserViewModel
//    @State var showActivity = false
    
    
    var body: some View {

        NavigationStack {
            ZStack {
                AppColors.backgroundColor
                    .ignoresSafeArea()
//                ScrollView {
                    VStack {
                        
                        StreakView()
                            .padding(.top, 50)
                        
                        BadgesView()
                        
                        TodaysActivitiesList()
                            
                        OfficeWorkOutView()
                            
                        Spacer()
                        
                        
//                        TodaysActivities(vm: myDayViewModel)
                        
                        
                    }
                }
            }
        
            
//        }
    }
    
}

struct OfficeWorkOutView: View {
    @EnvironmentObject var userData: UserViewModel
    var body: some View {
        VStack {
            Text("OFFICE WORKOUT")
                
                .foregroundColor(.white)
                .font(.system(size: 12))
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity,alignment: .leading)
                .padding(.leading, 30)
                .fontWeight(.bold)
                
            List {
                
                ForEach (userData.user.officeWorkOut) {workout in
                    HStack {
                        Text(workout.name)
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        Spacer()
                        Text("\(workout.repeatTimeHours, specifier: "%.1f")")
                            .foregroundColor(.white)
                            .padding(.trailing, 20)
                            
                    }
                }
                
                .listRowBackground(AppColors.backgroundColor)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

struct TodaysActivitiesList: View {
    
    @EnvironmentObject var userData: UserViewModel
    @State var selectedActivity : Activity? = nil
    var body: some View {
        VStack {
            Text("TODAYS ACTIVITIES")
                
                .foregroundColor(.white)
                .font(.system(size: 12))
                .fontDesign(.rounded)
                .frame(maxWidth: .infinity,alignment: .leading)
                .padding(.leading, 30)
                .offset(y: -10)
                .fontWeight(.bold)
            List {
                
                ForEach (userData.user.todaysActivities) { activity in
                    
                    TodaysActivities(activity: activity)
                        .onTapGesture {
                            selectedActivity = activity
                        }
                }
                .padding(.vertical, 2)
                .listRowInsets(.init())
            }
            .frame(height: 250)
            //            .offset(y: -40)
            
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            
        }
        .sheet(item: $selectedActivity) { activity in
            if activity.start == nil {
                
                ShowStartActivity(activity: activity)
                    .presentationBackground(.background)
                    .presentationDetents([.medium])
            }
            else {
                ShowStopActivity(activity: activity)
                    .presentationBackground(.background)
                    .presentationDetents([.medium])
            }
        }
    }
        
        
}


struct TodaysActivities: View {
    @EnvironmentObject var userData: UserViewModel
    var activity: Activity
    
    var body: some View {
        
        ZStack {
            if activity.end != nil {
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(AppColors.cardbackgroundColorEnd)
            } else if activity.start != nil {
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(AppColors.cardBackgroundColorStart)
            } else {
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(AppColors.cardBackgroundColor)
            }
            VStack {
                HStack {
                    Image(systemName: activity.category.image)
                        .padding(.leading)
                    Text(activity.name)
                        .font(.system(size: 14))
                    Spacer()
                    Image(systemName: "info.circle")
                        .padding(.trailing)
                    
                }
                HStack {
                    if activity.start != nil {
                        Image(systemName: activity.category.image)
                        Text(": \(activity.formattedDate(date: activity.start))")
                        
                    }
                    Spacer()
                    if(activity.end != nil) {
                        Image(systemName: "flag.checkered.2.crossed")
                        Text(": \(activity.formattedDate(date: activity.end))")
                    }
                }
                .padding(.top, 3)
                
            }
            
        }
        .frame(height: 100)
        .padding(.horizontal, 40)
        .listRowBackground(AppColors.backgroundColor)
    }
}

struct BadgesView: View {
    @EnvironmentObject var userData: UserViewModel
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(userData.user.badges ) { badge in
                    ZStack{
                        Image(badge.image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60)
                        Text(badge.name)
                            .font(.footnote)
                            .offset(y: -2)
                    }
                }
            }
            
            
            .scrollContentBackground(.hidden)
            .background(AppColors.backgroundColor)
        }
        .padding(.horizontal, 50)
        .frame(height: 100)
    }
}

struct StreakView : View {
    @EnvironmentObject var userData: UserViewModel
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0.2, to: 1)
                .rotation(.degrees(54))
                .stroke(
                    Color.blue.opacity(0.5),
                    lineWidth: 5
                )
            
            Circle()
                .trim(from: 0.2, to: 0.5)
                .rotation(.degrees(54))
                .stroke(
                    Color.green,
                    lineWidth: 5
                )
            VStack {
                Text("Days: ")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.bottom, 2)
                Text("12")
                    .foregroundColor(.green)
                    .fontWeight(.bold)
                    .padding(.bottom, 2)
                Text("Target: ")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.bottom, 2)
                Text("30")
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .fontWeight(.bold)
            }
        }.frame(width: 150, height: 150)
    }
}

struct ShowStartActivity : View {
    @EnvironmentObject var userData: UserViewModel
    @Environment(\.dismiss) var dismiss
    var activity: Activity
    
    var body: some View {
        ZStack {
            AppColors.backgroundColor
                .ignoresSafeArea()
            VStack {
                Text("Do you want to start \(activity.name)?")
                HStack {
                    Button(action: {
                        userData.startActivity(activity: activity)
                        dismiss()
                    }, label: {
                        Text("Yes")
                    })
                    Spacer()
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("No")
                    })
                }
            }
        }
        .scrollContentBackground(.hidden)
        
        
    }
}

struct ShowStopActivity : View {
    @EnvironmentObject var userData: UserViewModel
    @Environment(\.dismiss) var dismiss
    var activity: Activity
    
    var body: some View {
        ZStack {
            AppColors.backgroundColor
                .ignoresSafeArea()
            VStack {
                Text("Do you want to stop \(activity.name)?")
                HStack {
                    Button(action: {
                        userData.stopActivity(activity: activity)
                        dismiss()
                    }, label: {
                        Text("Yes")
                    })
                    Spacer()
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("No")
                    })
                }
            }
        }
        .scrollContentBackground(.hidden)
        
        
    }
}


#Preview {
    MyDayView()
        .environmentObject(UserViewModel())
}
