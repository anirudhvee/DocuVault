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

            if let topVC = UIApplication.shared.windows.first?.rootViewController?.presentedViewController {
                topVC.present(activityVC, animated: true)
            } else {
                UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true)
            }
        }
    }
}


struct Document: Identifiable {
    let id = UUID()
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
                    Button(action: {
                        let fileName = doc.name.lowercased()
                            .replacingOccurrences(of: " ", with: "_")
                            .replacingOccurrences(of: "'", with: "")
                        
                        if let url = Bundle.main.url(forResource: fileName, withExtension: "pdf") {
                            selectedDocumentURL = IdentifiableURL(url: url)
                           
                        } else {
               
                        }
                    }){
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
}


#Preview {
    IssuedDocumentsView()
        .environmentObject(DocumentStore())
}
