# FreshTrack - Smart Inventory Management

Welcome to the official Flutter application for **FreshTrack**, a smart refrigerator and inventory management app designed to track food expiration dates and prevent food waste.

This project is built with Flutter and Riverpod for state management, and it communicates directly with a Supabase backend for authentication, database, and storage services.

## 🏗️ Tech Stack

*   **Frontend:** Flutter (Riverpod State Management, GoRouter Navigation)
*   **Backend:** Supabase (PostgreSQL, Auth, Storage)
*   **Platforms:** Android, iOS (and others supported by Flutter)

## 🚀 Getting Started

### 1. Prerequisites
*   Flutter SDK installed (check with `flutter doctor`)
*   An editor like VS Code or Android Studio with the Flutter plugin.
*   Access to the project's Supabase instance.

### 2. Environment Setup
This project uses a `.env` file to manage Supabase credentials.

1.  Navigate to the `app_fresh_track` directory.
2.  Create a file named `.env` by copying the `.env.example`.
3.  Fill in the `SUPABASE_URL` and `SUPABASE_ANON_KEY` with the credentials from your Supabase project dashboard.

```env
# app_fresh_track/.env
SUPABASE_URL=YOUR_SUPABASE_URL_HERE
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY_HERE
```

### 3. Install Dependencies
Run the following command from the `app_fresh_track` directory to fetch all required packages:
```bash
flutter pub get
```

### 4. Run the Application
Start the application on your desired emulator or physical device:
```bash
flutter run
```

## 🗺️ Project Roadmap

The development of this application is broken down into several phases. For a detailed overview of the architecture, features, and QA scenarios for each phase, please refer to the main [ROADMAP.md](../../ROADMAP.md) in the root of the repository.
