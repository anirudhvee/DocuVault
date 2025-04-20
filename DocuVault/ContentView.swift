//
//  ContentView.swift
//  DocuVault
//
//  Created by Anirudh Venkatachalam on 4/19/25.
//
import SwiftUI
import JWTDecode

struct NoBounceScrollView<Content: View>: UIViewRepresentable {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
}

struct ContentView: View {
    @StateObject private var documentStore = DocumentStore()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Home")
                }
            
            SearchDocumentView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            
            IssuedDocumentsView()
                .tabItem {
                    Image(systemName: "doc.plaintext.fill")
                    Text("Issued")
                }
            
            UploadedDocumentsView()
                .tabItem {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text("Uploaded")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .environmentObject(documentStore)
    }
}

struct HomeView: View {
    @AppStorage("userName") var userName: String = ""
    @AppStorage("userPicture") var userPicture: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Fixed Header
            HStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
                
                Text("DocuVault")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding()
            .background(Color("AppPrimary"))
            
            NoBounceScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Welcome, \(userName.isEmpty ? "Guest" : userName)")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.white)
                                Text("Your documents are safe and sound")
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                            }
                            Spacer()
                            if let url = URL(string: userPicture), !userPicture.isEmpty {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color("AppPrimary"))
                    .padding(.bottom, 10)
                    
                    // Issued Documents
                    VStack (spacing : 5){
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
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                        }
                        
                    }
                    
                    // Trending News Banner
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("File your Taxes by April 15")
                                .font(.headline)
                            
                            Text("The IRS reminds everyone to submit federal tax returns before the deadline. Late filings may incur penalties.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Button("Learn More") {
                                // action
                            }
                            .padding(8)
                            .background(Color("AppPrimary"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "creditcard.fill")
                            .resizable()
                            .frame(width: 70, height: 50)
                            .foregroundColor(Color("AppPrimary"))
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("AppPrimary").opacity(0.1))
                    )
                    .padding(.horizontal)
                    
                    
                    // Utilities Section
                    Text("US Digital Locker Utility")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                        UtilityCard(icon: "dmv", title: "DMV")
                        UtilityCard(icon: "caliseal", title: "State")
                        UtilityCard(icon: "irs", title: "IRS")
                        
                        UtilityCard(icon: "anthem", title: "Health")
                        UtilityCard(icon: "ssa", title: "SSA")
                        UtilityCard(icon: "ucdavis", title: "Education")
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        Button("See More") {
                            // action
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color("AppPrimary"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        Spacer()
                    }
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
    var icon: String          // Name of the image or SF Symbol
    var title: String         // Title under the icon
    
    var body: some View {
        VStack {
            
            Image(icon) // Use image asset
                .resizable()
                .frame(width: 50, height: 50)
                .padding(13.5)
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

