//
//  AccountView.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var userData: UserViewModel
    @State var name: String = ""
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        AsyncImage(url: URL(string: userData.user.imageUrl ?? "")) {phase in
                            switch phase {
                            case .empty:
                                Image(systemName: "photo")
                                    .font(.title)
                            case .success(let image):
                                image
                                    .resizable()
                            case .failure(let error):
                                Image(systemName: "photo")
                                    .resizable()
                            default :
                                Image(systemName: "photo")
                            }
                            
                        }
                            
                            .frame(width: 150, height: 150)
                            .scaledToFit()
                            .padding(.leading, 30)
                        Spacer()
                        
                        TextField("Name", text: $name)
                            
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(20.0)
                            
                       
                    }
                    .padding(.trailing, 20)
                    .frame(height: 100)
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                    Spacer()
                    
                }
                Button("Save") {
                    userData.update(name: name)
                }
                
            }
            .navigationBarItems(trailing: Image(systemName: "rectangle.portrait.and.arrow.right")
                .onTapGesture {
                    userData.signOut()
                }
                .foregroundColor(.white))
            .onAppear() {
                name = userData.user.name
            }
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

