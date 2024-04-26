//
//  AccountView.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var userData: UserViewModel
    @State var name: String = "Jonas"
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        Image("badge_blue")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .scaledToFit()
                            .padding(.leading, 30)
                        Spacer()
                        
                        nameView(name: $name)
                            
                       
                    }
                    .frame(height: 100)
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                    AccountStreakView()
                    Spacer()
                    
                }
                
            }
            .navigationBarItems(trailing: Image(systemName: "rectangle.portrait.and.arrow.right")
                .foregroundColor(.white))
            
        }
    }
}

struct nameView: View {
    @Binding var name: String
    var body: some View {
        VStack {
            TextField("Name", text: $name)
                .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .border(.secondary)
                .padding(.horizontal, 10)
                .font(.title)
                .foregroundColor(.white)
            Spacer()
            
        }
        
    }
}

struct AccountStreakView: View {
    var body: some View {
        Text("streak")
            .foregroundColor(.white)
    }
}

#Preview {
    AccountView()
        .environmentObject(UserViewModel())
}

