import SwiftUI
import SwiftUI
import UIKit          // for UINotificationFeedbackGenerator
import AudioToolbox   // for AudioServicesPlaySystemSound
struct SearchDocumentView: View {
    @State private var searchText = ""
    let Documents: [Document] = [
        Document(name: "Driver's License", issuer: "California DMV", logoAsset: "dmv", hasVersionHistory: true, fileURL: nil),
        Document(name: "Vehicle Registration", issuer: "California DMV", logoAsset: "dmv", hasVersionHistory: true, fileURL: nil),
        Document(name: "Health Insurance", issuer: "Anthem Blue Cross", logoAsset: "anthem", hasVersionHistory: true, fileURL: nil),
        Document(name: "Utility Bill", issuer: "PG&E", logoAsset: "pge", hasVersionHistory: true, fileURL: nil),
        Document(name: "W-2", issuer: "IRS", logoAsset: "irs", hasVersionHistory: true, fileURL: nil),
        Document(name: "Birth Certificate", issuer: "State of California", logoAsset: "caliseal", hasVersionHistory: true, fileURL: nil),
        Document(name: "Social Security Card", issuer: "SSA", logoAsset: "ssa", hasVersionHistory: true, fileURL: nil),
        Document(name: "Degree Certificate", issuer: "University of California, Davis", logoAsset: "ucdavis", hasVersionHistory: true, fileURL: nil)
    ]


    var filteredGroupedByIssuer: [String: [Document]] {
        let lowercasedSearch = searchText.lowercased()

        let filtered = Documents.filter { doc in
            searchText.isEmpty || // Show all if empty
            doc.name.lowercased().contains(lowercasedSearch) ||
            doc.issuer.lowercased().contains(lowercasedSearch)
        }

        return Dictionary(grouping: filtered, by: { $0.issuer })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Search for Documents")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 50)
                        .padding(.horizontal)

                    TextField("Enter the name of a document to add", text: $searchText)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 1)
                        .padding(.horizontal)

                    ForEach(filteredGroupedByIssuer.keys.sorted(), id: \.self) { issuer in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(issuer)
                                    .font(.headline)
                                Spacer()
                                NavigationLink(destination: IssuerDocumentsView(
                                    issuer: issuer,
                                    documents: filteredGroupedByIssuer[issuer] ?? [])
                                ) {
                                    Text("View All")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)

                            ForEach(filteredGroupedByIssuer[issuer]!) { doc in
                                NavigationLink(destination: GetDocumentView(documentName: doc.name)) {
                                    HStack(spacing: 12) {
                                        Image(doc.logoAsset)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 36, height: 36)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(doc.name)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.blue)
                                            Text(doc.issuer)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }

                                        Spacer(minLength: 10)

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 1)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }

                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .background(Color(red: 0.95, green: 0.97, blue: 1.0).ignoresSafeArea())
        }
    }
}


// MARK: - Detail Page
struct GetDocumentView: View {
    @State private var showSuccessOverlay = false

    let documentName: String
    @State private var licenseNumber = ""
    @State private var isConsentGiven = false
    @EnvironmentObject var documentStore: DocumentStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(documentName)
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    
                    Group {
                        Text("Name (from ID)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("John Doe")
                        
                        Text("Date of Birth (from ID)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("1995-08-14")
                        
                        Text("\(documentName) Number *")
                        TextField("Example: XYZ123456", text: $licenseNumber)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        isConsentGiven.toggle()
                    }) {
                        HStack {
                            Image(systemName: isConsentGiven ? "checkmark.square.fill" : "square")
                                .foregroundColor(isConsentGiven ? .green : .gray)
                            Text("I provide my consent to DocuVault to fetch my documents.")
                                .font(.footnote)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button {
                         triggerSuccessAnimation {
                             if let details = documentStore.getDocumentDetails(for: documentName) {
                                 let newDoc = Document(
                                     name: documentName,
                                     issuer: details.issuer,
                                     logoAsset: details.logoAsset,
                                     hasVersionHistory: true,
                                     fileURL: nil
                                 )
                                 documentStore.addDocument(newDoc)
                                 dismiss()
                             }
                         }
                     } label: {
                         Text("GET DOCUMENT")
                             .frame(maxWidth: .infinity)
                             .padding()
                             .background(Color.purple)
                             .foregroundColor(.white)
                             .cornerRadius(12)
                     }
                     .disabled(!isConsentGiven ||
                               licenseNumber.trimmingCharacters(in: .whitespaces).isEmpty)
                     .opacity((isConsentGiven &&
                               !licenseNumber.trimmingCharacters(in: .whitespaces).isEmpty)
                              ? 1.0 : 0.5)
                     .padding(.top)

                     Spacer()
                 }
                 .padding()
             }

            // Success overlay
            if showSuccessOverlay {
                Color.black.opacity(0.5).ignoresSafeArea()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.green)
                    .scaleEffect(showSuccessOverlay ? 1.0 : 0.5)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6),
                               value: showSuccessOverlay)
            }
        }
        .navigationTitle("Get Document")
        .navigationBarTitleDisplayMode(.inline)
    }
    

    private func triggerSuccessAnimation(andThen completion: @escaping ()->Void) {
        showSuccessOverlay = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(1104)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { showSuccessOverlay = false }
            completion()
        }
    }
}
struct IssuerDocumentsView: View {
    let issuer: String
    let documents: [Document]

    var body: some View {
        VStack(alignment: .leading) {
            Text(issuer)
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)
                .padding(.horizontal)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(documents) { doc in
                        NavigationLink(destination: GetDocumentView(documentName: doc.name)) {
                            HStack(spacing: 12) {
                                Image(doc.logoAsset)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 36, height: 36)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))

                                VStack(alignment: .leading) {
                                    Text(doc.name)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                    Text(doc.issuer)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer(minLength: 10)

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top)
            }
        }
        .background(Color(red: 0.95, green: 0.97, blue: 1.0).ignoresSafeArea())
    }
}
