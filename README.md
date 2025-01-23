---

# Flutter Chat App

A real-time chat application built using **Flutter** and **Firebase**, providing users with essential messaging features and a clean, intuitive interface.

## Features

- **User Signup and Login**  
  Authenticate users securely using Firebase Authentication.  

- **Real-Time Chat**  
  Instant messaging powered by Firebase Firestore for real-time updates.  

- **User Search**  
  Search for users to initiate new conversations.  

- **File Sharing (UI Placeholder)**  
  The app includes a file-sharing feature in the UI, though its functionality is not yet implemented.  

## Tech Stack

- **Frontend**: Flutter  
- **Backend**: Firebase (Authentication & Firestore and s3 as an object storage)

---

## Folder Structure

<details>
<summary>Click to expand</summary>

```
lib/
├── main.dart          // Entry point of the app
├──helper/            // Helper functions for uploader and notification provider
├── pages/          // all Uis and logics (auth, Firestore operations , chat and all pages)
├── models/            // Data models for users and messages         
```

</details>

---

## Setup and Installation

To get started with the app, follow these steps:

### 1. **Clone the Repository**
```bash
git clone https://github.com/yordil/flutter-ChatApp
cd flutter-ChatApp
```

### 2. **Set Up Flutter**
Ensure you have Flutter installed. If not, follow the [Flutter installation guide](https://docs.flutter.dev/get-started/install).

### 3. **Install Dependencies**
Run the following command to install the required dependencies:
```bash
flutter pub get
```

### 4. **Firebase Setup**
- Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
- Add an Android and/or iOS app to your Firebase project.
- Download the configuration file:
  - `google-services.json` (for Android)  
  - `GoogleService-Info.plist` (for iOS)  
- Place the file in the appropriate directory:
  - Android: `android/app/`
  - iOS: `ios/Runner/`

### 5. **Configure Firestore Security Rules**
Update Firestore rules to ensure secure access for authenticated users:
```json
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 6. **Run the App**
Run the application using the following command:
```bash
flutter run
```
