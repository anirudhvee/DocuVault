import SwiftUI
import VisionKit
import PDFKit

struct UploadedDocumentsView: View {
    @State private var uploadedDocs: [UploadedDocument] = []
    @State private var showingScanner = false
    @State private var showingInfoForm = false
    @State private var showingVersionHistoryFor: UploadedDocument? = nil
    @State private var selectedVersionImage: UIImage? = nil
    @State private var newDocumentImage: UIImage? = nil
    @State private var newDocName = ""
    @State private var showingFileImporter = false
    @State private var newDocIssuer = ""
    @State private var showingAddOptions = false


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
                        Button(action: {
                            selectedVersionImage = doc.latestVersion.image
                        }) {
                            HStack(spacing: 14) {
                                Image(uiImage: doc.latestVersion.image)
                                    .resizable()
                                    .frame(width: 45, height: 45)
                                    .cornerRadius(6)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(doc.name)
                                        .font(.headline)
                                    Text(doc.issuer)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("Recently Updated: \(doc.latestVersion.date.formatted(date: .abbreviated, time: .shortened))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if doc.versions.count > 1 {
                                    Button(action: {
                                        showingVersionHistoryFor = doc
                                    }) {
                                        Image(systemName: "clock.arrow.circlepath")
                                            .foregroundColor(.purple)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.vertical, 6)
                    }
                    .onDelete(perform: deleteDocuments)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Uploaded Documents")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Scan Document", systemImage: "camera.fill") {
                            showingScanner = true
                        }
                        
                        Button("Upload from Files", systemImage: "folder.fill") {
                            showingFileImporter = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .confirmationDialog("Add Document", isPresented: $showingAddOptions, titleVisibility: .visible) {
                Button("Scan Document") {
                    showingScanner = true
                }

                Button("Upload from Files") {
                    showingFileImporter = true
                }

                Button("Cancel", role: .cancel) {}
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
                                let version = DocumentVersion(image: image, date: Date())
                                if let index = uploadedDocs.firstIndex(where: { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == newDocName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() && $0.issuer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == newDocIssuer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }) {
                                    uploadedDocs[index].versions.insert(version, at: 0)
                                } else {
                                    let newDoc = UploadedDocument(
                                        name: newDocName,
                                        issuer: newDocIssuer,
                                        versions: [version]
                                    )
                                    uploadedDocs.append(newDoc)
                                }
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
            .sheet(item: $showingVersionHistoryFor) { doc in
                NavigationView {
                    List {
                        let grouped = Dictionary(grouping: doc.versions.dropFirst()) { version in
                            Calendar.current.dateComponents([.year, .month], from: version.date)
                        }

                        let sortedKeys = grouped.keys.sorted { lhs, rhs in
                            if let lYear = lhs.year, let rYear = rhs.year, lYear != rYear {
                                return lYear > rYear
                            }
                            if let lMonth = lhs.month, let rMonth = rhs.month {
                                return lMonth > rMonth
                            }
                            return false
                        }

                        ForEach(sortedKeys, id: \.self) { key in
                            if let month = key.month, let year = key.year, let versions = grouped[key] {
                                Section(header: Text("\(DateFormatter().monthSymbols[month - 1]) \(year)")) {
                                    ForEach(versions) { version in
                                        NavigationLink(destination: PDFViewer(image: version.image)) {
                                            HStack(spacing: 12) {
                                                Image(uiImage: version.image)
                                                    .resizable()
                                                    .frame(width: 45, height: 45)
                                                    .cornerRadius(6)
                                                VStack(alignment: .leading) {
                                                    Text("\(version.date.formatted(date: .abbreviated, time: .shortened))")
                                                        .font(.headline)
                                                }
                                            }
                                            .padding(.vertical, 6)
                                        }
                                    }
                                }
                            }
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
            .sheet(isPresented: $showingFileImporter) {
                DocumentPickerView { importedImage in
                    newDocumentImage = importedImage
                    showingInfoForm = true
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
    var name: String
    var issuer: String
    var versions: [DocumentVersion]

    var latestVersion: DocumentVersion {
        versions.first ?? DocumentVersion(image: UIImage(systemName: "doc")!, date: Date())
    }
}

struct DocumentVersion: Identifiable {
    let id = UUID()
    let image: UIImage
    let date: Date
}

struct PDFViewer: View {
    var image: UIImage

    var body: some View {
        if let pdfData = imageToPDF(image: image), let doc = PDFDocument(data: pdfData) {
            PDFKitView(pdfDocument: doc)
        } else {
            Text("Failed to generate PDF.")
                .foregroundColor(.red)
        }
    }

    func imageToPDF(image: UIImage) -> Data? {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: image.size))
        return pdfRenderer.pdfData { context in
            context.beginPage()
            image.draw(at: .zero)
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {}
}

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
struct DocumentPickerView: UIViewControllerRepresentable {
    var onDocumentPicked: (UIImage) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentPicked: onDocumentPicked)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.image, .pdf])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onDocumentPicked: (UIImage) -> Void

        init(onDocumentPicked: @escaping (UIImage) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }

            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }

                if url.pathExtension.lowercased() == "pdf",
                   let pdfDoc = PDFDocument(url: url),
                   let page = pdfDoc.page(at: 0) {
                    let bounds = page.bounds(for: .mediaBox)
                    if let ctx = CGContext(data: nil, width: Int(bounds.width), height: Int(bounds.height), bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
                       let cgPage = page.pageRef {
                        ctx.drawPDFPage(cgPage)
                        if let cgImage = ctx.makeImage() {
                            let uiImage = UIImage(cgImage: cgImage)
                            onDocumentPicked(uiImage)
                        }
                    }
                } else if let data = try? Data(contentsOf: url),
                          let image = UIImage(data: data) {
                    onDocumentPicked(image)
                }
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            controller.dismiss(animated: true)
        }
    }
}


extension UIImage: Identifiable {
    public var id: UUID { UUID() }
}

#Preview {
    UploadedDocumentsView()
}
