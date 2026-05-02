<div align="center">

<img src="assets/icons/icon.png" alt="GreenBasket+ Logo" width="120" height="120"/>

# 🌿 GreenBasket+

### *Your Daily Preventive Health Companion*

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Groq](https://img.shields.io/badge/Groq-LLaMA_3-FF6B35?style=for-the-badge&logo=meta&logoColor=white)](https://groq.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**GreenBasket+ turns small daily habits into lifelong health.**
**Because the best hospital visit is the one you never need.**

[🚀 Live Demo](https://greenbasket-plus.web.app) • [✨ Features](#-features) • [📱 Screenshots](#-screenshots) • [🛠 Installation](#-installation) 

</div>

---

## 💡 The Problem We're Solving

> **80% of premature heart disease, stroke, and type 2 diabetes cases are preventable.**
> Yet millions of people worldwide forget medicines, skip health checkups, and ignore early warning signs — not out of carelessness, but because no tool makes it simple enough to stay consistent.

Most health apps are either:
- ❌ Too complex and overwhelming
- ❌ Too expensive for everyday users
- ❌ Focused on fitness fanatics, not regular people
- ❌ Reactive — they treat illness instead of preventing it

**GreenBasket+ fixes all of that.**

---

## 🌿 What is GreenBasket+?

GreenBasket+ is an **AI-powered preventive health companion** that works quietly in the background of your daily life — reminding, guiding, and motivating you before problems become serious.

Unlike traditional health apps that focus heavily on calorie counting, GreenBasket+ focuses on **habit-based health improvement** — making preventive care simple, accessible, and sustainable for everyone.

```
Not a doctor. Not a hospital.
Just your smartest daily health habit.
```

---

## 📱 Screenshots

### Splash & Dashboard

| Splash Screen | Daily Health Score | Activity Tracking | Medicine Reminders |
|:---:|:---:|:---:|:---:|
| ![Splash](https://github.com/user-attachments/assets/3098a4a3-786c-4654-bb96-7ca525270f65) | ![Dashboard](https://github.com/user-attachments/assets/a52a3f90-58ce-4213-98e1-0cf41c1b2c78) | ![Activity](https://github.com/user-attachments/assets/c3117a39-b745-4e96-8fd0-7cf5f2eb99d3) | ![Medicines](https://github.com/user-attachments/assets/8679fd3d-66e4-457f-b51a-c766bb6dffaf) |

### GreenBot & Health Risk Insights

| GreenBot AI Chat | Risk Assessment | BMI & Calculate | Disease Results |
|:---:|:---:|:---:|:---:|
| ![GreenBot](https://github.com/user-attachments/assets/bc9f4ebd-128f-458e-a5ca-53f7b0ad502e) | ![Risk 1](https://github.com/user-attachments/assets/881728d2-2c19-4f63-907b-32d28b143b42) | ![Risk 2](https://github.com/user-attachments/assets/591d8ab8-55ae-4c57-a595-3451a90f5d0f) | ![Risk 3](https://github.com/user-attachments/assets/7aa9e8ad-bdd7-41f9-9c85-d053ba28d798) |


> 🌐 **Try it live:** [greenbasket-plus.web.app](https://greenbasket-plus.web.app)

---

## ✨ Features

### 🤖 GreenBot — AI Health Assistant
> Powered by **Groq API + LLaMA 3** for instant, accurate responses

- Ask anything — nutrition, symptoms, lifestyle, motivation
- Personalised responses based on your health profile
- Chat history saved to cloud — like Claude / ChatGPT
- Quick suggestion chips for common health questions
- Responsible AI — advises, never diagnoses
- Medical disclaimer on every session

### 💊 Smart Medicine Reminders
- Add medicines with custom reminder times
- Mark as taken with one tap
- Track missed doses and adherence percentage
- Visual adherence dashboard

### 📊 Daily Health Score
- Score out of 100 based on completed habits
- `Health Score = (Completed Habits ÷ Total Habits) × 100`
- Visual circular progress indicator
- Motivates consistency, not perfection

### 🏃 Lifestyle Habit Tracking
- Walking, water intake, sleep, fruits, weekly weight
- Daily progress bars with goals
- Personalised daily suggestions every morning
- Adapts to health conditions (diabetes, hypertension, etc.)

### 🔬 Health Risk Insights

**Disease Risk Assessment:**
- Diabetes, Heart Disease, Blood Pressure, Obesity
- Rule-based scoring: age, BMI, lifestyle, exercise, sleep, smoking
- Colour-coded risk bars — Low / Moderate / High
- Personalised advice per condition

**Nutrient Deficiency Detection:**
- Iron, Calcium, Vitamin D, Vitamin A, B12, Zinc, Magnesium
- Real symptoms shown — eye dryness (Vit A), skin peeling (B12)
- Food recommendations to fix each deficiency
- Expandable cards with full details

### 🔔 Checkup Reminders
- Scheduled health checkup reminders (dental, BP, etc.)
- Due Now / In Xd status badges
- Never miss a preventive checkup again

---

## 🏗 Architecture

```
GreenBasket+
├── 📱 Frontend          Flutter (Android + iOS + Web)
├── 🔐 Authentication    Firebase Auth
├── 🗄 Database          Cloud Firestore (real-time)
├── 🤖 AI Engine         Groq API + LLaMA 3.3-70B
├── 💬 Chat History      Firestore conversations collection
└── 🔔 Notifications     Flutter Local Notifications
```

### Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Mobile App | Flutter 3.x | Cross-platform Android, iOS & Web |
| Language | Dart 3.x | App logic |
| Authentication | Firebase Auth | Secure user login |
| Database | Cloud Firestore | Real-time cloud storage |
| AI Chatbot | Groq + LLaMA 3 | Health guidance |
| State Management | Provider | App state |
| Hosting | Firebase Hosting | Web deployment |

---

## 🛠 Installation

### Prerequisites

- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`
- Firebase project set up
- Groq API key from [console.groq.com](https://console.groq.com) *(free)*

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/mikkiiee33/Green_Basket_plus.git
cd Green_Basket_plus
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Set up environment variables**

Create a `.env` file in the root folder:
```env
GROQ_API_KEY=your_groq_api_key_here
```

**4. Set up Firebase**
- Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- Download `google-services.json` → place in `android/app/`
- Download `GoogleService-Info.plist` → place in `ios/Runner/`

**5. Run the app**
```bash
flutter run
```

**6. Build for release**
```bash
# Android APK
flutter build apk --release

# Web
flutter build web
firebase deploy --only hosting
```

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants & enums
│   ├── services/           # Groq API, Firebase services
│   └── theme/              # App theme & colors
├── models/                 # Data models
├── providers/              # State management (Provider)
├── screens/
│   ├── auth/               # Login & signup
│   ├── chatbot/            # GreenBot + chat history
│   ├── dashboard/          # Home dashboard
│   ├── habits/             # Habit tracking
│   ├── medications/        # Medicine reminders
│   ├── profile_setup/      # User onboarding
│   └── risk_insights/      # Disease prediction + nutrient check
└── widgets/                # Reusable UI components
```

---

## 🔐 Security

- All user data stored securely on Firebase Cloud Firestore
- API keys managed through environment variables (`.env`)
- `.env` excluded from version control via `.gitignore`
- Firebase Security Rules — users can only access their own data
- GreenBot includes medical disclaimer on every session

---

## ⚠️ Disclaimer

GreenBasket+ is a **wellness companion app** and does **not** provide medical diagnosis. All health information is for general awareness only. Always consult a qualified healthcare professional for medical advice, diagnosis, or treatment.

---



## 👨‍💻 Author

Built with ❤️ for a healthier world.

[![GitHub](https://img.shields.io/badge/GitHub-mikkiiee33-black?style=for-the-badge&logo=github)](https://github.com/mikkiiee33)

---


<div align="center">

**🌿 GreenBasket+ — Small habits. Big impact. Global reach.**

*Made with Flutter • Powered by Groq LLaMA • Backed by Firebase*

⭐ **If GreenBasket+ inspires you, give it a star!** ⭐

</div>
