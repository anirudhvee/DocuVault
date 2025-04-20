//
//  DocuVaultApp.swift
//  DocuVault
//
//  Created by Anirudh Venkatachalam on 4/19/25.
//

import SwiftUI

@main
struct DocuVaultApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView() 
            } else {
                LoginView()
            }
        }
    }
}
