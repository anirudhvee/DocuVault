import SwiftUI

class DocumentStore: ObservableObject {
    @Published var documents: [Document] = []
    
    private let documentDetails: [String: (issuer: String, logoAsset: String)] = [
        "Driver's License": ("California DMV", "dmv"),
        "Vehicle Registration": ("California DMV", "dmv"),
        "Health Insurance": ("Anthem Blue Cross", "anthem"),
        "Utility Bill": ("PG&E", "pge"),
        "W-2": ("IRS", "irs"),
        "Birth Certificate": ("State of California", "caliseal"),
        "Social Security Card": ("SSA", "ssa"),
        "Degree Certificate": ("University of California, Davis", "ucdavis")
    ]
    
    func getDocumentDetails(for name: String) -> (issuer: String, logoAsset: String)? {
        return documentDetails[name]
    }
    
    func addDocument(_ document: Document) {
        if !documents.contains(where: { $0.name == document.name && $0.issuer == document.issuer }) {
            documents.append(document)
        }
    }
    
    func removeDocument(_ document: Document) {
        documents.removeAll { $0.id == document.id }
    }
} 