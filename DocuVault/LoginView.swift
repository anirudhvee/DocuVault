//
//  LoginView.swift
//  DocuVault
//
//  Created by Nandhana Selvam on 4/19/25.
//

import SwiftUI
import Auth0

struct LoginView: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to DocuVault")
                .font(.title)
                .bold()

            Button(action: login) {
                Text("Login")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    func login() {
        Auth0
            .webAuth()
            .useHTTPS()
            .start { result in
                switch result {
                case .success(let credentials):
                    print("Obtained credentials: \(credentials)")
                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
    }
}

#Preview {
    LoginView()
}
