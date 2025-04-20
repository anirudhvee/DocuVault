import SwiftUI
import Auth0
import JWTDecode

struct LoginView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userPicture") var userPicture: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    @State private var showLoginButton = false

    var body: some View {
        ZStack {
            Color.appPrimary
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "lock.shield.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)

                    Image("docuvault")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 60) // or any size you want

                    Text("All your documents, in one place.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    Spacer().frame(height: 60) // ✅ pushes the button upward

                }

                Spacer()

                if showLoginButton {
                    Button(action: login) {
                        Text("Login")
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showLoginButton = true
                }
            }
        }
    }

    func login() {
        Auth0
            .webAuth()
            .useHTTPS()
            .start { result in
                switch result {
                case .success(let credentials):
                    isLoggedIn = true
                    print("✅ Logged in! Credentials: \(credentials)")

                    // Decode ID Token and extract user info
                    guard let jwt = try? decode(jwt: credentials.idToken),
                          let name = jwt["name"].string,
                          let picture = jwt["picture"].string else {
                        print("❌ Failed to decode user info")
                        return
                    }

                    print("Name: \(name)")
                    print("Picture URL: \(picture)")

                    userName = name
                    userPicture = picture
                    isLoggedIn = true

                case .failure(let error):
                    print("❌ Login failed: \(error)")
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
                    print("✅ Logged out")
                    isLoggedIn = false
                    userName = ""
                    userPicture = ""
                case .failure(let error):
                    print("❌ Logout failed: \(error)")
                }
            }
    }
}

#Preview {
    LoginView()
}
