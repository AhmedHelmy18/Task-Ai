# 🐋 Whale Task: Smart Productivity AI

Whale Task is a premium, state-of-the-art productivity application that merges advanced task management with the power of **Gemini AI**. Designed with a focus on visual excellence and seamless user experience, Whale Task transforms how you plan, organize, and achieve your goals.

![Whale Task Header](assets/images/whale-logo2.png)

---

## ⚡ Core Pillars

### 🤖 Intelligent Assistance (Gemini AI)

Whale Task isn't just a list; it's a collaborator. Using the **Gemini AI Engine**, the app offers:

- **Conversational Task Creation**: Just talk to the AI about your goals, and it will intelligently extract and suggest sub-tasks.
- **Contextual Suggestions**: Receive smart ideas on how to organize your day.
- **Natural Language Input**: "I need to plan a marketing campaign by next Friday" becomes a structured set of tasks automatically.

### 🎨 Visual Excellence

The UI is crafted for a premium "wow" factor:

- **Glassmorphism Design**: Subtle blur effects and reflective surfaces throughout the interface.
- **Dynamic Animations**: Smooth transitions powered by Flutter's animation engine.
- **Lucide Iconography**: Clean, modern icons for a professional look.
- **Radial Gradients**: Deep, immersive dark mode using curated HSL color palettes.

### 🧩 Feature-First Architecture

Built for scalability and maintainability, the project uses a feature-driven structure:

- **AI Chat**: A dedicated hub for AI interactions.
- **Focus Mode**: Specialized views for "My Day", "Planned", and "Important" tasks.
- **Smart Calendar**: Integrated `table_calendar` for high-performance scheduling.
- **Notifications**: Local and Firebase-backed reminders to keep you on track.

---

## 🏗️ Technical Deep Dive

### State Management: Flutter BLoC

We utilize `flutter_bloc` to ensure a predictable state lifecycle. The architecture separates concerns into:

- **Events**: User actions (e.g., `CreateTaskEvent`).
- **States**: UI representation (e.g., `TaskLoadingState`, `TaskSuccessState`).
- **Cubits**: Lightweight logic handlers for simpler features (e.g., `AuthCubit`).

### Backend Infrastructure

- **Firebase Auth**: Secure multi-method authentication (Google Sign-in, Email/Password).
- **Cloud Firestore**: Real-time NoSQL database for instant task synchronization.
- **Cloud Functions**: Serverless logic for AI processing and heavy lifting.
- **Firebase Messaging**: Robust push notification delivery.

### Directory Structure

```text
lib/
├── app/                  # App routing and global providers
├── core/                 # Design system, constants, and global widgets
│   ├── theme/           # Radial gradients and HSL color tokens
│   └── widgets/         # Glassmorphism cards and common loaders
└── features/             # Feature-specific modules
    ├── ai_chat/          # AI interaction logic and UI
    ├── auth/             # Login, Signup, and Onboarding
    ├── tasks/            # CRUD for task management
    └── calendar/         # High-resolution scheduling
```

---

## 🛠️ Advanced Setup

### Firebase Configuration

1. Initialize a new Firebase project at [Firebase Console](https://console.firebase.google.com/).
2. Enable **Firestore**, **Authentication**, and **Cloud Messaging**.
3. Run `flutterfire configure` to generate `firebase_options.dart`.
4. (Optional) Setup **Cloud Functions** for AI processing.

### Gemini API Integration

1. Obtain an API Key from the [Google AI Studio](https://aistudio.google.com/).
2. Add your key to a `.env` file or secure storage (ensure it's not committed to VCS).
3. The app uses `google_generative_ai` package for interaction.

### Local Development

To run the project locally with full features:

```bash
flutter pub get
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

---

## 🚀 Roadmap

- [ ] AI-driven productivity reports.
- [ ] Shared collaborative lists.
- [ ] Desktop and Web support.
- [ ] Integration with Google Calendar and Outlook.

---

_Whale Task - Empowering your productivity with the weight of the deep sea._
