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
    @State var activityName : String = ""
    
    var body: some View {
        ZStack {
            AppColors.backgroundColor
                .ignoresSafeArea()
            VStack {
                
                Picker("", selection: $selectedActivity) {
                    ForEach(userData.activityStats) { activity in
                        Text("\(activity.name)").tag(activity as ActivityStats)
                        
                    }
                }
                Text("\(activityName)")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                TabView {
//                    Text("First")
//                    Text("Second")
//                    Text("Third")
                    StatsChart(entries: selectedActivity.entriesDay, name: selectedActivity.name, timePeriod: "Today")
                    StatsChart(entries: selectedActivity.entriesWeek, name: selectedActivity.name, timePeriod: "This week")
                    StatsChart(entries: selectedActivity.entriesMonth, name: selectedActivity.name, timePeriod: "This month")
                    StatsChart(entries: selectedActivity.entries, name: selectedActivity.name, timePeriod: "Since start")
                }
                .tabViewStyle(.page)
//                Chart(selectedActivity.entries, id: \.date) {entry in
//                    if let totalTime = entry.totalTime {
//                        if let date = entry.date {
//                            BarMark(
//                                x: .value("Date", date, unit: .day),
//                                y: .value("Time", totalTime)//, width: 20
//                            )
//                            .cornerRadius(10)
//                            
//                        }
//                    }
//                    
//                }
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
        }
        .onAppear(){
//            userData.getActivityStats()
            guard let selectedActivity = userData.activityStats.first else {return}
            print("got it")
            
        }
    }
    
}

struct StatsChart : View {
    var entries : [ActivityEntry]
    var name : String
    var timePeriod : String
    var body: some View {
        VStack {
            Text("\(timePeriod)")
                .foregroundColor(.white)
                .font(.title)
            Chart(entries, id: \.date) {entry in
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
            .chartXAxis {AxisMarks(values: .automatic) {
                AxisValueLabel()
                    .foregroundStyle(.white)
            }
            }
            .chartYAxis {AxisMarks(values: .automatic) {
                
                AxisValueLabel()
                    .foregroundStyle(.white)
            }
            }
            .chartYAxisLabel(position: .leading, alignment: .center) {
                Text("Time")
            }
        }
    }
}

//
//#Preview {
//    ActivityStatsView()
//}
