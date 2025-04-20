import SwiftUI

struct Document: Identifiable {
    let id = UUID()
    var name: String
    var issuer: String
    var logoAsset: String
    var hasVersionHistory: Bool
    var fileURL: URL? // Placeholder, use real file later
}

struct IssuedDocumentsView: View {
    @EnvironmentObject var documentStore: DocumentStore
    @State private var searchText = ""
    
    var filteredDocuments: [Document] {
        if searchText.isEmpty {
            return documentStore.documents
        } else {
            return documentStore.documents.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search for documents", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                List(filteredDocuments) { doc in
                    HStack {
                        if let uiImage = UIImage(named: doc.logoAsset) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: "doc.text") // fallback system icon
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.purple)
                        }

                        VStack(alignment: .leading) {
                            Text(doc.name)
                                .font(.headline)
                            Text(doc.issuer)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        Menu {
                            Button("Open File") {
                                // TODO: Integrate QuickLook or UIDocumentInteractionController
                                print("Open file for \(doc.name)")
                            }
                            
                            if doc.hasVersionHistory {
                                Button("View Previous Versions") {
                                    // TODO: Navigate to version list
                                    print("View versions for \(doc.name)")
                                }
                            }
                            
                            Button("Remove Document", role: .destructive) {
                                documentStore.removeDocument(doc)
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Issued Documents")
        }
    }
}

#Preview {
    IssuedDocumentsView()
        .environmentObject(DocumentStore())
}
