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
    @State var activityName : String = ""
    
    var body: some View {
        ZStack {
            AppColors.backgroundColor
                .ignoresSafeArea()
            VStack {
                Text("Statistics about your activities")
                    .foregroundColor(.white)
                    .font(.title)
                Picker( selection: $selectedActivity, label: Text("Select an activity")) {
                    Text("Select an activity").tag("Select an activity")
                    ForEach(userData.activityStats) { activity in
                        Text("\(activity.name)").tag(activity as ActivityStats)
                    }
                }
                TabView {
                    StatsChart(entries: selectedActivity.entriesDay, name: selectedActivity.name, timePeriod: "Today")
                    StatsChart(entries: selectedActivity.entriesWeek, name: selectedActivity.name, timePeriod: "This week")
                    StatsChart(entries: selectedActivity.entriesMonth, name: selectedActivity.name, timePeriod: "This month")
                    StatsChart(entries: selectedActivity.entries, name: selectedActivity.name, timePeriod: "Since start")
                }
                .tabViewStyle(.page)
                .opacity(selectedActivity.name == "placeHolderEmpty" ? 0.0 : 1.0)
                .frame(height: 300)
                .padding(50)
            }
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
                        .foregroundStyle(AppColors.gradient)
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
