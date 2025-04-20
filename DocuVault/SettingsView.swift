//
//  SettingsView.swift
//  DocuVault
//
//  Created by Nandhana Selvam on 4/19/25.
//

import SwiftUI
import Auth0
import PhotosUI

struct SettingsView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userPicture") var userPicture: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Profile")) {
                    TextField("Name", text: $userName)

                    HStack(alignment: .center, spacing: 20) {
                        if let imageData = selectedImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else if userPicture.starts(with: "http"),
                                  let url = URL(string: userPicture) {
                              // Case 1: Remote URL from Auth0
                              AsyncImage(url: url) { image in
                                  image.resizable()
                              } placeholder: {
                                  ProgressView()
                              }
                              .frame(width: 80, height: 80)
                              .clipShape(Circle())
                          } else if let url = URL(string: userPicture), url.isFileURL {
                              // Case: local file URL
                              if let imageData = try? Data(contentsOf: url),
                                 let uiImage = UIImage(data: imageData) {
                                  Image(uiImage: uiImage)
                                      .resizable()
                                      .frame(width: 80, height: 80)
                                      .clipShape(Circle())
                              } else {
                                  Image(systemName: "person.crop.circle")
                                      .resizable()
                                      .frame(width: 80, height: 80)
                                      .foregroundColor(.gray)
                              }
                          }


                        // Picker beside or beneath profile picture
                        VStack(alignment: .leading) {
                            Text("Update your photo")
                                .font(.subheadline)
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                photoLibrary: .shared()
                            ) {
                                Text("Choose from library")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }

                Section {
                    Button(role: .destructive) {
                        logout()
                    } label: {
                        Text("Logout")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Settings")
        }
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                   let savedPath = saveImageToDocuments(data) {
                    selectedImageData = data
                    userPicture = savedPath
                }
            }
        }
    }

    func logout() {
        Auth0
            .webAuth()
            .useHTTPS()
            .clearSession { result in
                switch result {
                case .success:
                    isLoggedIn = false
                    userName = ""
                    userPicture = ""
                    selectedImageData = nil
                    print("✅ Logged out from settings")
                case .failure(let error):
                    print("❌ Logout failed: \(error)")
                }
            }
    }
    
    func saveImageToDocuments(_ data: Data) -> String? {
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)

        do {
            try data.write(to: url)
            return url.absoluteString
        } catch {
            print("❌ Failed to save image:", error)
            return nil
        }
    }

}

#Preview {
    SettingsView()
}
