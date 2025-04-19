//
//  issueddocs.swift
//  DocuVault
//
//  Created by Rohan Malige on 4/19/25.
//

import SwiftUI

struct IssuedDocumentsView: View {
    @State private var searchText: String = ""

    var body: some View {
        ZStack {
            // Background Color (Soft pastel)
            Color(red: 0.95, green: 0.97, blue: 1.0) // Light pastel blue
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                // Top Title
                Text("DocuVault")
                    .font(.system(size: 34, weight: .bold))
                    .padding(.top, 50)
                    .padding(.horizontal)

                // Search Bar
                TextField("Search documents...", text: $searchText)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)

                // Trending Documents Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Trending Documents")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            TrendingBox(title: "Driving License")
                            TrendingBox(title: "W-2 Tax Form")
                            TrendingBox(title: "Social Security Card")
                        }
                        .padding(.horizontal)
                    }

                    Text("Newly Added")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            TrendingBox(title: "Passport Renewal")
                            TrendingBox(title: "Medical Insurance Card")
                        }
                        .padding(.horizontal)
                    }
                }

                Spacer()
            }
        }
    }
}

struct TrendingBox: View {
    let title: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 28))
                .foregroundColor(.blue)

            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
        }
        .frame(width: 140, height: 100)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}
