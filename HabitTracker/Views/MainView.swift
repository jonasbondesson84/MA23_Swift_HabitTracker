//
//  ContentView.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userData: UserViewModel
    
    var body: some View {
        TabView {
            MyDayView()
                .tabItem {
                    Label("My day", systemImage: "medal.fill")
                        .foregroundStyle(Color.red)
                }
            ActivityView()
                .tabItem {
                    Label("Activities", systemImage: "figure.walk")
                }
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }
        }
        .tint(.red)
        .onAppear(perform: {
            UITabBar.appearance().unselectedItemTintColor = .gray
            userData.checkSignIn()
        })
    }
}

#Preview {
    MainView()
        .environmentObject(UserViewModel())
}
