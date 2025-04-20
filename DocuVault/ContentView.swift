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
    @EnvironmentObject var documentStore: DocumentStore
    @State private var selectedDocumentURL: IdentifiableURL? = nil
    
    var body: some View {
        NavigationStack {
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
                                    Text("All your documents, in one place")
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
                        VStack(spacing: 5) {
                            HStack {
                                Text("Issued Documents")
                                    .font(.headline)
                                Spacer()
                                NavigationLink {
                                    IssuedDocumentsView()
                                } label: {
                                    Text("See All")
                                        .padding(.horizontal)
                                        .padding(.vertical, 6)
                                        .background(Color.gray.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(documentStore.documents) { document in
                                        DocumentCard(
                                            title: document.name,
                                            id: "ID: \(document.id.uuidString.prefix(8))",
                                            issuer: document.issuer,
                                            onTap: {
                                                let fileName = document.name.lowercased()
                                                    .replacingOccurrences(of: " ", with: "_")
                                                    .replacingOccurrences(of: "'", with: "")
                                                
                                                if let url = Bundle.main.url(forResource: fileName, withExtension: "pdf") {
                                                    selectedDocumentURL = IdentifiableURL(url: url)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                            }
                            .id(documentStore.documents.count)
                        }
                        
                        // Trending News Banner
                        HStack(alignment: .center) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Forgot to File Your Taxes?")
                                    .font(.headline)
                                
                                Text("You should file your federal tax returns now to avoid penalties and interest charges.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                NavigationLink {
                                    SearchDocumentView(initialSearch: "IRS")
                                } label: {
                                    Text("View Tax Statements")
                                        .padding(8)
                                        .background(Color("AppPrimary"))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                            }
                            
                            Spacer()
                            
                            Image("irs")
                                .resizable()
                                .frame(width: 60, height: 60)
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
                            NavigationLink {
                                SearchDocumentView(initialSearch: "California DMV")
                            } label: {
                                UtilityCard(icon: "dmv", title: "DMV")
                            }
                            NavigationLink {
                                SearchDocumentView(initialSearch: "State of California")
                            } label: {
                                UtilityCard(icon: "caliseal", title: "State")
                            }
                            NavigationLink {
                                SearchDocumentView(initialSearch: "SSA")
                            } label: {
                                UtilityCard(icon: "ssa", title: "SSA")
                            }
                            
                            NavigationLink {
                                SearchDocumentView(initialSearch: "Anthem Blue Cross")
                            } label: {
                                UtilityCard(icon: "anthem", title: "Health")
                            }
                            NavigationLink {
                                SearchDocumentView(initialSearch: "IRS")
                            } label: {
                                UtilityCard(icon: "irs", title: "IRS")
                            }
                            NavigationLink {
                                SearchDocumentView(initialSearch: "University of California")
                            } label: {
                                UtilityCard(icon: "ucdavis", title: "Education")
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Spacer()
                            NavigationLink {
                                SearchDocumentView()
                            } label: {
                                Text("See More")
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color("AppPrimary"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(item: $selectedDocumentURL) { identifiable in
                PDFPreviewController(
                    url: identifiable.url,
                    onDismiss: {
                        selectedDocumentURL = nil
                    }
                )
            }
        }
    }
}

struct DocumentCard: View {
    var title: String
    var id: String
    var issuer: String
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
            .background(Color(.systemGray6))
            .cornerRadius(15)
            .shadow(radius: 4)
        }
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

