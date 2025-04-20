import SwiftUI
import VisionKit

struct UploadedDocumentsView: View {
    @State private var uploadedDocs: [UploadedDocument] = []
    @State private var showingScanner = false
    @State private var showingInfoForm = false
    @State private var newDocumentImage: UIImage? = nil
    @State private var newDocName = ""
    @State private var newDocIssuer = ""

    var body: some View {
        NavigationView {
            List {
                if uploadedDocs.isEmpty {
                    VStack(alignment: .center) {
                        Spacer()
                        Text("No documents uploaded yet.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(uploadedDocs) { doc in
                        HStack(spacing: 14) {
                            Image(uiImage: doc.image)
                                .resizable()
                                .frame(width: 45, height: 45)
                                .cornerRadius(6)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(doc.name)
                                    .font(.headline)
                                Text(doc.issuer)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete(perform: deleteDocuments)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Uploaded")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingScanner = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingScanner) {
                DocumentCameraView { scannedImage in
                    newDocumentImage = scannedImage
                    showingScanner = false
                    showingInfoForm = true
                }
            }
            .sheet(isPresented: $showingInfoForm) {
                NavigationView {
                    Form {
                        Section(header: Text("Document Details")) {
                            TextField("Document Name", text: $newDocName)
                            TextField("Issuing Entity", text: $newDocIssuer)
                        }

                        Button("Save") {
                            if let image = newDocumentImage {
                                let newDoc = UploadedDocument(
                                    name: newDocName,
                                    issuer: newDocIssuer,
                                    image: image
                                )
                                uploadedDocs.append(newDoc)
                                resetNewDocFields()
                            }
                        }
                        .disabled(newDocName.isEmpty || newDocIssuer.isEmpty)
                    }
                    .navigationTitle("New Document")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                resetNewDocFields()
                            }
                        }
                    }
                }
            }
        }
    }

    private func deleteDocuments(at offsets: IndexSet) {
        uploadedDocs.remove(atOffsets: offsets)
    }

    private func resetNewDocFields() {
        newDocName = ""
        newDocIssuer = ""
        newDocumentImage = nil
        showingInfoForm = false
    }
}

struct UploadedDocument: Identifiable {
    let id = UUID()
    let name: String
    let issuer: String
    let image: UIImage
}

// MARK: - VisionKit Camera Wrapper
struct DocumentCameraView: UIViewControllerRepresentable {
    var onScanComplete: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onScanComplete: onScanComplete)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var onScanComplete: (UIImage) -> Void

        init(onScanComplete: @escaping (UIImage) -> Void) {
            self.onScanComplete = onScanComplete
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            controller.dismiss(animated: true)
            if scan.pageCount > 0 {
                onScanComplete(scan.imageOfPage(at: 0))
            }
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            controller.dismiss(animated: true)
            print("Scan failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    UploadedDocumentsView()
}
