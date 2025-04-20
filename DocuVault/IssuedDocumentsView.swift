import SwiftUI

struct Document: Identifiable {
    let id = UUID()
    var name: String
    var issuer: String
    var hasVersionHistory: Bool
    var fileURL: URL? // Placeholder, use real file later
}

struct IssuedDocumentsView: View {
    
    // Temporary hardcoded sample documents
    let documents: [Document] = [
        Document(name: "Driver's License", issuer: "California DMV", hasVersionHistory: true, fileURL: nil),
        Document(name: "Vehicle Registration", issuer: "California DMV", hasVersionHistory: true, fileURL: nil),
        Document(name: "Health Insurance", issuer: "Covered California", hasVersionHistory: true, fileURL: nil),
        Document(name: "Utility Bill", issuer: "PG&E", hasVersionHistory: true, fileURL: nil),
        Document(name: "W-2", issuer: "IRS", hasVersionHistory: true, fileURL: nil),
        Document(name: "Birth Certificate", issuer: "County Registrar", hasVersionHistory: true, fileURL: nil),
        Document(name: "Social Security Card", issuer: "SSA", hasVersionHistory: true, fileURL: nil),
        Document(name: "Degree Certificate", issuer: "UC Davis", hasVersionHistory: true, fileURL: nil)
    ]
    
    var body: some View {
        NavigationView {
            List(documents) { doc in
                HStack {
                    Image(systemName: "doc.text")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.purple)
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
            .navigationTitle("Issued Documents")
        }
    }
}
