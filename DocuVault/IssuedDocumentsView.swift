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
    
    // Temporary hardcoded sample documents
    let allDocuments: [Document] = [
        Document(name: "Driver's License", issuer: "California DMV", logoAsset: "dmv", hasVersionHistory: true, fileURL: nil),
        Document(name: "Vehicle Registration", issuer: "California DMV", logoAsset: "dmv", hasVersionHistory: true, fileURL: nil),
        Document(name: "Health Insurance", issuer: "Anthem Blue Cross", logoAsset: "anthem", hasVersionHistory: true, fileURL: nil),
        Document(name: "Utility Bill", issuer: "PG&E", logoAsset: "pge", hasVersionHistory: true, fileURL: nil),
        Document(name: "W-2", issuer: "IRS", logoAsset: "irs", hasVersionHistory: true, fileURL: nil),
        Document(name: "Birth Certificate", issuer: "State of California", logoAsset: "caliseal", hasVersionHistory: true, fileURL: nil),
        Document(name: "Social Security Card", issuer: "SSA", logoAsset: "ssa", hasVersionHistory: true, fileURL: nil),
        Document(name: "Degree Certificate", issuer: "University of California, Davis", logoAsset: "ucdavis", hasVersionHistory: true, fileURL: nil)
    ]

    
    @State private var searchText = ""
    
    var filteredDocuments: [Document] {
        if searchText.isEmpty {
            return allDocuments
        } else {
            return allDocuments.filter { $0.name.lowercased().contains(searchText.lowercased()) }
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
}
