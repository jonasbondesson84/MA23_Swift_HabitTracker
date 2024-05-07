//
//  AppColors.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import Foundation
import SwiftUI

struct AppColors {
    static let backgroundColor = Color(red: 18/256, green: 29/256, blue: 47/256)
    static let sheetBackgroundColor = Color(red: 18/256, green: 60/256, blue: 100/256)
    static let sheetBackgroundColorDark = Color(red: 152/256, green: 92/256, blue: 217/256)
    static let sheetBackgroundColorLight = Color(red: 77/256, green: 187/256, blue: 255/256)
    static let cardBackgroundColor = Color(red: 243/256, green: 189/256, blue: 120/256)
    static let cardbackgroundColorEnd = Color(red: 1/256, green: 165/256, blue: 126/256)
    static let cardBackgroundColorStart = Color(red: 164/256, green: 222/256, blue: 233/256)
    static let cardShadowColor = Color(red: 182/256, green: 248/256, blue: 219/256)
    static let buttonColor = Color(red: 1/256, green: 165/256, blue: 126/256)
    static let textFieldBackgroundColor = Color(red: 164/256, green: 222/256, blue: 233/256)
    static let transparent = Color(red: 1/256, green: 1/256, blue: 1/256, opacity: 0.0)
    
    static let gradient = LinearGradient(gradient: Gradient(colors: [AppColors.cardbackgroundColorEnd, AppColors.backgroundColor]), startPoint: .top, endPoint: .bottom)
}
