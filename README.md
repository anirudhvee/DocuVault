# DocuVault 

Meet DocuVault - our vision for modern document management that brings clarity to chaos. We've reimagined how people interact with their important documents, creating an intuitive space where everything from tax forms to vehicle registrations is just a tap away. This prototype showcases how document management could be both powerful and delightfully simple.

<div align="center">
  <img src="https://i.imgur.com/IDDPHRd.png" alt="DocuVault App Screenshots showing login, home, and search screens" width="100%">
</div>

> **Important Note**: DocuVault is a prototype created for HackDavis 2025 to demonstrate the concept of unified document management. This is not a production application and has no affiliation with any government agencies, financial institutions, or document issuers (DMV, IRS, SSA, insurance providers, etc.). All branding elements and references are used for demonstration purposes only.

## Why DocuVault? 🎯

Let's face it - keeping track of important documents is a hassle. They're scattered across email, physical papers, and various websites. We've built this prototype to explore how document management could be more enjoyable. Here's what makes our concept different:

- 🔐 **Everything in One Place**: From scanned documents to official papers, everything lives in one clean, organized space
- 📅 **Smart Organization**: Documents are automatically sorted and tagged so you can find them in seconds
- 🔍 **Quick Search**: Find any document instantly - no more digging through folders or emails
- 📱 **Built for Mobile**: A smooth, native iOS experience that feels natural and intuitive
- 📊 **Version History**: Keep track of document updates without the confusion

## Technical Implementation 🛠️

### Built With
- **Frontend**: SwiftUI and UIKit
- **Authentication**: Auth0 and JWTDecode
- **Document Handling**: 
  - VisionKit for document scanning
  - PDFKit for PDF previews
  - QuickLook for document previews
- **Data Management**:
  - UserDefaults for local storage
  - JSONEncoder/Decoder for data persistence
- **UI Components**:
  - PhotosUI for profile image handling
  - Custom SwiftUI views for document management

### Project Structure
- `ContentView.swift`: Main app interface
- `LoginView.swift`: Authentication handling
- `DocumentStore.swift`: Document management logic
- `UploadedDocumentsView.swift`: Uploaded documents interface
- `IssuedDocumentsView.swift`: Issued documents interface
- `searchdocs.swift`: Document search functionality
- `SettingsView.swift`: User settings and preferences

## Team 

- **Anirudh Venkatachalam** ([@anirudhvee](https://github.com/anirudhvee))
- **Manasvini Narayanan** ([@mana-nara](https://github.com/mana-nara))
- **Nandhana Selvam** ([@nandhanaselvam](https://github.com/nandhanaselvam))
- **Rohan Malige** ([@rohanmalige](https://github.com/rohanmalige))

