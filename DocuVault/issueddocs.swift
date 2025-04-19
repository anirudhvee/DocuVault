//
//  issueddocs.swift
//  DocuVault
//
//  Created by Rohan Malige on 4/19/25.
//

import SwiftUI
struct DocumentItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let location: String
}

struct DepartmentSection: Identifiable {
    let id = UUID()
    let title: String
    let documents: [DocumentItem]
}


struct SearchDocumentView: View {
    let trendingDocs = ["Tax Return","Driving License", "Social Security Card"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.97, blue: 1.0).ignoresSafeArea() // Pastel background

                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("DocuVault")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 50)
                        .padding(.horizontal)

                    // Search Bar
                    TextField("Search for documents", text: .constant(""))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 1)
                        .padding(.horizontal)

                    // Trending Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(trendingDocs, id: \.self) { doc in
                                NavigationLink(destination: GetDocumentView(documentName: doc)) {
                                    Label(doc, systemImage: "arrow.up.right")
                                        .padding(.vertical, 8)
                                        .padding(.horizontal)
                                        .background(Color.white)
                                        .cornerRadius(25)
                                        .shadow(radius: 1)
                                }
                            }
                        }.padding(.horizontal)
                    }

                    // Most Popular Section
                    Text("Most Popular Documents")
                        .font(.headline)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(trendingDocs, id: \.self) { doc in
                                NavigationLink(destination: GetDocumentView(documentName: doc)) {
                                    VStack {
                                        Image(systemName: "doc.text.fill")
                                            .resizable()
                                            .frame(width: 50, height: 50)
                                            .padding()
                                            .foregroundColor(.blue)

                                        Text(doc)
                                            .font(.caption)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 140, height: 120)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .shadow(radius: 3)
                                }
                            }
                        }.padding(.horizontal)
                    }

                    Spacer()
                }
            }
        }
    }
}
struct GetDocumentView: View {
    let documentName: String
    @State private var licenseNumber = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text(documentName)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                // Example Fields
                Group {
                    Text("Name (from ID)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("John Doe")

                    Text("Date of Birth (from ID)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("1995-08-14")

                    Text("\(documentName) Number *")
                    TextField("Example: XYZ123456", text: $licenseNumber)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }

                // Consent
                HStack {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(.green)
                    Text("I provide my consent to DocuVault to fetch my documents.")
                        .font(.footnote)
                }

                // Get Button
                Button(action: {
                    // Add your backend logic here
                }) {
                    Text("GET DOCUMENT")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Get Document")
        .navigationBarTitleDisplayMode(.inline)
    }
}
