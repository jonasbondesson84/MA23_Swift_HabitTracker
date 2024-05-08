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
                        .foregroundStyle(AppColors.cardBackgroundColor)
                }
            ActivityView()
                .tabItem {
                    Label("Activities", systemImage: "figure.walk")
                }
            ActivityStatsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.xaxis")
                }
            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }
        }
        .tint(AppColors.cardbackgroundColorEnd)
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
