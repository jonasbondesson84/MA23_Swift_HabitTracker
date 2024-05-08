//
//  AccountView.swift
//  HabitTracker
//
//  Created by Jonas Bondesson on 2024-04-26.
//

import SwiftUI
import PhotosUI


struct AccountView: View {
    @EnvironmentObject var userData: UserViewModel
    @State var name: String = ""
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State var uiImage: UIImage?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundColor
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        ZStack {
                            if uiImage != nil {
                                Image(uiImage: uiImage!)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                                    .padding(.leading, 30)
                            } else {
                                AsyncImage(url: URL(string: userData.user.imageUrl ?? "")) {phase in
                                    switch phase {
                                    case .empty:
                                        Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(AppColors.cardBackgroundColorStart)
                                            .background(.gray)
                                            .frame(width: 150, height: 150)
                                            .clipShape(Circle())
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .frame(width: 150, height: 150)
                                            .clipShape(Circle())
                                    case .failure(let error):
                                        Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(AppColors.cardBackgroundColorStart)
                                            .background(.gray)
                                            .frame(width: 150, height: 150)
                                            .clipShape(Circle())
                                    default :
                                        Image(systemName: "person.crop.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(AppColors.cardBackgroundColorStart)
                                            .background(.gray)
                                            .frame(width: 150, height: 150)
                                            .clipShape(Circle())
                                    }
                                }
                                .scaledToFill()
                                .padding(.leading, 30)
                            }
                            PhotosPicker(
                                selection: $selectedPhoto,
                                matching: .images,
                                photoLibrary: .shared()) {
                                    Image(systemName: "photo.badge.plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(.white)
                                }
                                .offset(x: 50, y: 50)
                        }
                        TextField("Name", text: $name)
                            .padding()
                            .background(AppColors.textFieldBackgroundColor)
                            .cornerRadius(20.0)
                            .padding(.trailing, 20)
                            .frame(height: 100)
                            .padding(.top, 50)
                            .padding(.bottom, 20)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
                    Spacer()
                    Button("Save") {
                        userData.update(name: name, image: uiImage)
                    }
                    Spacer()
                    Spacer()
                }
            }
            .navigationBarItems(trailing: Image(systemName: "rectangle.portrait.and.arrow.right")
                .onTapGesture {
                    userData.signOut()
                }
                .foregroundColor(.white))
        }
        .onAppear() {
            name = userData.user.name
            uiImage = nil
        }
        .onChange(of: selectedPhoto) { result in
            Task {
                do {
                    if let data = try await selectedPhoto?.loadTransferable(type: Data.self) {
                        if let uiImage = UIImage(data: data) {
                            self.uiImage = uiImage
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                    selectedPhoto = nil
                }
            }
        }
    }
}

#Preview {
    AccountView()
        .environmentObject(UserViewModel())
}

