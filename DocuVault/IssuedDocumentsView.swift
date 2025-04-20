import SwiftUI
import QuickLook

struct PDFPreviewController: UIViewControllerRepresentable {
    let url: URL
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let previewController = QLPreviewController()
        previewController.dataSource = context.coordinator

        let navigationController = UINavigationController(rootViewController: previewController)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(Coordinator.dismiss))
        previewController.navigationItem.leftBarButtonItem = doneButton
        
        return navigationController
    }

    func updateUIViewController(_ controller: UINavigationController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(url: url, onDismiss: onDismiss)
    }

    class Coordinator: NSObject, QLPreviewControllerDataSource {
        let url: URL
        let onDismiss: () -> Void

        init(url: URL, onDismiss: @escaping () -> Void) {
            self.url = url
            self.onDismiss = onDismiss
        }

        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            return 1
        }

        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            return url as QLPreviewItem
        }

        @objc func dismiss() {
            onDismiss()
        }

        @objc func share() {
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)

            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let topVC = windowScene.windows.first?.rootViewController?.presentedViewController {
                topVC.present(activityVC, animated: true)
            } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                windowScene.windows.first?.rootViewController?.present(activityVC, animated: true)
            }
        }
    }
}


struct Document: Identifiable, Codable {
    var id = UUID()
    var name: String
    var issuer: String
    var logoAsset: String
    var hasVersionHistory: Bool
    var fileURL: URL? // Placeholder, use real file later
}
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct IssuedDocumentsView: View {
    @EnvironmentObject var documentStore: DocumentStore
    @State private var searchText = ""
    @State private var selectedDocumentURL: IdentifiableURL? = nil
    @State private var showingVersionHistoryFor: Document? = nil
  
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
                
                List {
                    ForEach(filteredDocuments) { doc in
                        Button(action: {
                            let fileName = doc.name.lowercased()
                                .replacingOccurrences(of: " ", with: "_")
                                .replacingOccurrences(of: "'", with: "")
                            
                            if let url = Bundle.main.url(forResource: fileName, withExtension: "pdf") {
                                selectedDocumentURL = IdentifiableURL(url: url)
                            }
                        }) {
                            HStack {
                                if let uiImage = UIImage(named: doc.logoAsset) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                } else {
                                    Image(systemName: "doc.text")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(Color("AppPrimary"))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(doc.name)
                                        .font(.headline)
                                    Text(doc.issuer)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                if doc.hasVersionHistory {
                                    Button(action: {
                                        showingVersionHistoryFor = doc
                                    }) {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .foregroundColor(Color("AppPrimary"))
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }

                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .onDelete(perform: deleteDocument)
                }
                .navigationTitle("Issued Documents")
                .sheet(item: $selectedDocumentURL) { identifiable in
                    PDFPreviewController(
                        url: identifiable.url,
                        onDismiss: {
                            selectedDocumentURL = nil
                        }
                    )
                }
                .sheet(item: $showingVersionHistoryFor) { doc in
                    NavigationView {
                        List {

                            ForEach(0..<3, id: \.self) { i in
                                //BUTTON SHOULD OPEN UP ORIGINAL DOCUMENT
                                Button(action: {
                                    // First, dismiss the version history sheet
                                    showingVersionHistoryFor = nil

                                    // Then open the PDF after a slight delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        let fileName = (doc.name + "_v\(i + 1)")
                                            .lowercased()
                                            .replacingOccurrences(of: " ", with: "_")
                                            .replacingOccurrences(of: "'", with: "")

                                        if let url = Bundle.main.url(forResource: fileName, withExtension: "pdf") {
                                            selectedDocumentURL = IdentifiableURL(url: url)
                                        } else if let fallbackURL = Bundle.main.url(forResource: doc.name.lowercased().replacingOccurrences(of: " ", with: "_"), withExtension: "pdf") {
                                            selectedDocumentURL = IdentifiableURL(url: fallbackURL)
                                        }
                                    }
                                }) {
                                    HStack {
                                        if let uiImage = UIImage(named: doc.logoAsset) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .frame(width: 45, height: 45)
                                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                        } else {
                                            Image(systemName: "doc.text")
                                                .resizable()
                                                .frame(width: 35, height: 45)
                                                .foregroundColor(Color("AppPrimary"))
                                        }
                                        
                                        // placeholder version control dates
                                        Text(
                                            i == 0 ? "Mar 20, 2025 at 12:00 PM" :
                                            i == 1 ? "Jan 15, 2024 at 9:30 AM" :
                                            i == 2 ? "Sep 3, 2023 at 3:45 PM" :
                                            "Jul 27, 2022 at 11:15 AM"
                                        )
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }

                            
                        }
                        .navigationTitle("Previous Versions")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") {
                                    showingVersionHistoryFor = nil
                                }
                            }
                        }
                    }
                }

                
            }
        }
    }
    
    func deleteDocument(at offsets: IndexSet) {
        for index in offsets {
            let doc = filteredDocuments[index]
            documentStore.removeDocument(doc)
        }
    }
}


#Preview {
    IssuedDocumentsView()
        .environmentObject(DocumentStore())
}
