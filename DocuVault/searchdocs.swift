//
//  searchdocs.swift
//  DocuVault
//
//  Created by Rohan Malige on 4/19/25.
//

import SwiftUI

struct Document: Identifiable {
    let id = UUID()
    let name: String
    let issuer: String
    let hasVersionHistory: Bool
    let fileURL: URL?
}

struct SearchDocumentView: View {
    @State private var searchText = ""

    let documents: [Document] = [
        Document(name: "Driver's License", issuer: "California DMV", hasVersionHistory: true, fileURL: nil),
        Document(name: "Vehicle Registration", issuer: "California DMV", hasVersionHistory: true, fileURL: nil),
        Document(name: "Health Insurance", issuer: "Covered California", hasVersionHistory: true, fileURL: nil),
        Document(name: "Utility Bill", issuer: "PG&E", hasVersionHistory: true, fileURL: nil),
        Document(name: "W-2", issuer: "IRS", hasVersionHistory: true, fileURL: nil),
        Document(name: "Birth Certificate", issuer: "County Registrar", hasVersionHistory: true, fileURL: nil),
        Document(name: "Social Security Card", issuer: "SSA", hasVersionHistory: true, fileURL: nil),
        Document(name: "Degree Certificate", issuer: "UC Davis", hasVersionHistory: true, fileURL: nil)
    ]

    var groupedByIssuer: [String: [Document]] {
        Dictionary(grouping: documents, by: { $0.issuer })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("DocuVault")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 50)
                        .padding(.horizontal)

                    TextField("Search for documents", text: $searchText)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 1)
                        .padding(.horizontal)

                    ForEach(groupedByIssuer.keys.sorted(), id: \.self) { issuer in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(issuer)
                                    .font(.headline)
                                Spacer()
                                Button("View All") {
                                    // Optional future nav
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal)

                            ForEach(groupedByIssuer[issuer]!) { doc in
                                NavigationLink(destination: GetDocumentView(documentName: doc.name)) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.green)

                                        VStack(alignment: .leading) {
                                            Text(doc.name)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.blue)
                                            Text(issuer)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }

                                        Spacer(minLength: 10) // Smaller spacer than full push

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8) // Adds nice breathing room
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 1)
                                    .padding(.horizontal)
                                }
                                
                            }
                        }
                        .padding(.top, 8)
                    }

                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .background(Color(red: 0.95, green: 0.97, blue: 1.0).ignoresSafeArea())
        }
    }
}


// MARK: - Detail Page
struct GetDocumentView: View {
    let documentName: String
    @State private var licenseNumber = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(documentName)
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

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

                HStack {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(.green)
                    Text("I provide my consent to DocuVault to fetch my documents.")
                        .font(.footnote)
                }

                Button(action: {
                    // Add backend logic here
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
