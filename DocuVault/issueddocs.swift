//
//  issueddocs.swift
//  DocuVault
//
//  Created by Rohan Malige on 4/19/25.
//

import SwiftUI

struct DocuVaultView: View {
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            Color("PastelBackground") // Add this color to Assets.xcassets
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                Text("DocuVault")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                // Search Bar
                TextField("Search documents...", text: $searchText)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Trending Documents
                VStack(alignment: .leading, spacing: 16) {
                    Text("Most Popular Documents")
                        .font(.headline)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            TrendingCard(title: "Driving License")
                            TrendingCard(title: "W-2 Tax Form")
                            TrendingCard(title: "Social Security Card")
                        }.padding(.horizontal)
                    }

                    Text("Newly Added Documents")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            TrendingCard(title: "Passport Renewal")
                            TrendingCard(title: "Medical Insurance Card")
                        }.padding(.horizontal)
                    }
                }

                Spacer()
            }
            .padding(.horizontal)
        }
    }
}
