# PureCheck - AI Skincare Allergen & Suitability Tracker

Welcome to the official Flutter application for **PureCheck**, a centralized skincare verification engine. PureCheck is designed to prevent allergic reactions and analyze product suitability by combining barcode scanning, external data fetching, Human-in-the-Loop verification, and AI-driven reasoning tailored to your individual skin profile.

## 🏗️ Key Features
*   **Authentication & Personalization:** Secure user login and personalized skin profile (Skin Type, Concerns, Allergen History).
*   **Smart Barcode Scanning:** Identify products instantly via barcode scanning.
*   **AI-Powered Analysis:** Aggregates verified ingredient lists with user profiles to highlight red flags (allergens) and suitability for your skin type via Gemini AI.
*   **Human-in-the-Loop Verification:** Crowdsourced verification for products not found in the master database.
*   **Self-Feeding Knowledge Base:** Verified product data is cached to the Master Database via secure Edge Functions, ensuring fast future verification.

## 🛠️ Tech Stack
*   **Frontend:** Flutter (State Management: Riverpod)
*   **Backend & Database:** Supabase (Auth, PostgreSQL, Edge Functions)
*   **AI Engine:** Google Gemini API
*   **External Data APIs:** Open Beauty Facts API

## 🚀 Getting Started

### 1. Prerequisites
*   Flutter SDK
*   Access to a Supabase project (Remote or Local)
*   Google Gemini API Key

### 2. Environment Setup
1.  Navigate to `app_pure_check/`.
2.  Create `.env` based on `.env.example`.
3.  Configure `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `GEMINI_API_KEY`.

```env
# app_pure_check/.env
SUPABASE_URL=YOUR_SUPABASE_URL_HERE
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY_HERE
GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE
```

### 3. Install & Run
Run these commands from the `app_pure_check/` directory:

```bash
flutter pub get
flutter run
```

## 🗺️ Project Roadmap
The development of this application is broken down into five phases, focusing on an **Architecture First** approach. For a detailed overview of the architecture, database schema, and QA scenarios, please refer to the main [ROADMAP.md](../ROADMAP.md) in the root of the repository.
