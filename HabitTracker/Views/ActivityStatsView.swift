//
//  ActivityCalendarView.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-05-10.
//

import SwiftUI
import Charts

struct ActivityStatsView: View {
    
    @EnvironmentObject var userData : UserViewModel
    @State var selectedActivity: ActivityStats = .emptyStats
//    @State var selectedActivity = 0
    
    var body: some View {
        VStack {
//            ScrollView {
                Picker("", selection: $selectedActivity) {
                    ForEach(userData.activityStats) { activity in
                        Text("\(activity.name)").tag(activity as ActivityStats)
                    }
                }
//                Text(userData.activityStats[selectedActivity].name)
                Chart(selectedActivity.entries, id: \.date) {entry in
                    if let totalTime = entry.totalTime {
                        if let date = entry.date {
                            BarMark(
                                x: .value("Date", date, unit: .day),
                                y: .value("Time", totalTime)//, width: 20
                            )
                            .cornerRadius(10)
                            
                        }
                    }
                    
                }
//                .chartYAxis(.hidden)
                
                .frame(height: 300)
                .padding(50)
//            ForEach(userData.activityStats) {stats in
//                
//                    Text(stats.name)
//                    Chart(stats.entries, id: \.date) {entry in
//                        //                    if let totalTime = entry.totalTime {
//                        if let date = entry.date {
//                            BarMark(
//                                x: .value("Date", date),
//                                y: .value("Time", 5)
//                            )
//                        }
//                    }
//                    //                }
//                }
//            }
        }
        .onAppear(){
            userData.getActivityStats()
        }
    }
    
}
//
//#Preview {
//    ActivityStatsView()
//}
