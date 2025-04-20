import SwiftUI
import Auth0
import JWTDecode

struct LoginView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userPicture") var userPicture: String = ""
    //@State private var isLoggedIn: Bool = false //used for testing, does not save across app restarts
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

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
