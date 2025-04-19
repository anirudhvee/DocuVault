//
//  ContentView.swift
//  DocuVault
//
//  Created by Anirudh Venkatachalam on 4/19/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Home")
                }
            
            Text("Search")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }

            Text("Issued")
                .tabItem {
                    Image(systemName: "doc.plaintext.fill")
                    Text("Issued")
                }

            Text("Uploaded")
                .tabItem {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text("Uploaded")
                }

            Text("Setting")
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                        
                }
        }
    }
}

struct HomeView: View {
    var body: some View {
        // Purple header
        ZStack(alignment: .top) {
            Color.purple
                .ignoresSafeArea()
                .frame(height: 112)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header text
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Welcome, John Doe")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            Text("Digital IDs are valid per the U.S. E-Sign Act, 2000")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                        Spacer()
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    .padding()
                    
                    // Issued Documents
                    HStack {
                        Text("Pinned Documents")
                            .font(.headline)
                        Spacer()
                        Button("See All") {
                            // Action
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            DocumentCard(title: "Driver's License", id: "xxxxxxxx1234", issuer: "Department of Motor Vehicles")
                            DocumentCard(title: "Social Security", id: "xxx-xx-6789", issuer: "SSA")
                        }
                        .padding()
                    }
                    
                    
                    // Trending News Banner (auto-sizing)
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("File your Taxes by April 15")
                                .font(.headline)

                            Text("The IRS reminds all citizens to submit federal tax returns before the deadline. Late filings may incur penalties.")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Button("Learn More") {
                                // action
                            }
                            .padding(8)
                            .background(Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }

                        Spacer()

                        Image(systemName: "creditcard.fill")
                            .resizable()
                            .frame(width: 70, height: 50)
                            .foregroundColor(.purple)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.purple.opacity(0.1))
                    )
                    .padding(.horizontal)

                    
                    // Utilities Section
                    Text("US Digital Locker Utility")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                        UtilityCard(icon: "car.fill", title: "DMV")
                        UtilityCard(icon: "building.columns.fill", title: "State")
                        UtilityCard(icon: "creditcard.fill", title: "IRS")
                        
                        UtilityCard(icon: "heart.text.square.fill", title: "Health")
                        UtilityCard(icon: "person.text.rectangle", title: "SSA")
                        UtilityCard(icon: "graduationcap.fill", title: "Education")
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct DocumentCard: View {
    var title: String
    var id: String
    var issuer: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(id)
                .font(.subheadline)
                .foregroundColor(.gray)
            Text(issuer)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 200, height: 100)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 4)
    }
}

struct UtilityCard: View {
    var icon: String
    var title: String

    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 35, height: 35)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
            Text(title)
                .font(.caption)
        }
        .padding(8)
    }
}

#Preview {
    ContentView()
}

