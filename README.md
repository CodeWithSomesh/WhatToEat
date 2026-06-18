<div align="center">
  <img src="https://raw.githubusercontent.com/github/explore/80688e429a7d4ef2fca1e82350fe8e3517d3494d/topics/flutter/flutter.png" width="100" />
</div>

<h1 align="center">WhatToEat 🍽️</h1>
<p align="center">
  <b>Optimize meal decision-making for individuals and groups with ease and fun.</b><br/>
</p>

<p align="center">
  <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev/"><img src="https://img.shields.io/badge/Language-Dart-0175C2?logo=dart&logoColor=white" alt="Dart"></a>
  <a href="https://firebase.google.com/"><img src="https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black" alt="Firebase"></a>
  <a href="#"><img src="https://img.shields.io/badge/License-MIT-green" alt="License: MIT"></a>
</p>

---

## 🌟 The Motivation

The daily decision-making process regarding meal selection poses a persistent challenge for numerous individuals, particularly in professional and social settings. This seemingly simple question, **"What should we eat?"**, becomes exponentially complex when multiple individuals are involved, transforming from a personal preference decision into a collaborative negotiation that often results in decision fatigue, social friction, and suboptimal outcomes.

> *Research in decision science highlights that food choice decisions are frequent, multifaceted, situational, dynamic, and complex. These choices are often influenced by immediate factors such as time constraints, emotional states, and social dynamics.*

Empirical observations within Malaysian workplaces reveal that employees consistently allocate between **25 to 45 minutes daily** to lunch destination negotiations. This contributes to measurable productivity losses and elevated decision fatigue levels. The significance of addressing this challenge extends beyond mere convenience, with substantial implications for workplace productivity and mental health:

- A proper lunch break provides essential time for meals, social interactions, and stress reduction.
- The economic impact of unaddressed mental health challenges related to work stress is colossal globally.

### Why not just use existing platforms?
While platforms like Yelp and Zomato dominate restaurant discovery, they overwhelmingly design for **solo users**, creating a fundamental mismatch between actual user behavior (average dining party of 3.7 individuals) and available solutions. They lack mechanisms to systematically collect, weigh, and reconcile multiple individuals' preferences in real-time, often leading to psychological pitfalls such as "groupthink."

**WhatToEat** bridges this gap. By applying principles of user experience design that reduce cognitive load through simplified interfaces and interactive, organized information, we aim to streamline the decision process. Our ultimate goal is measurable improvements in decision-making efficiency, user satisfaction, culinary exploration rates, and cultural preservation by highlighting local culinary traditions.

---

## ✨ Features

- 🎡 **Interactive Decision Wheels**  
  Can't decide? Let fate choose! Use the **Auto Spin** or **Manual Spin** wheels to objectively and fairly select a dining spot, featuring fun animations, confetti, and satisfying sound effects.

- 📍 **Smart Location-Based Discovery**  
  Integrated location services map out nearby restaurants instantly so you always know what's around you.

- 🔍 **Advanced Search & Restaurant Finder**  
  Filter, search, and discover your next culinary destination effortlessly with our sleek user interface.

- ❤️ **Curated Favourites List**  
  Loved a spot? Save it to your Personal Favourites so you can quickly revisit or advocate for it in your next group outing.

- 🔐 **Secure User Authentication & Profiles**  
  Seamlessly sign in or register through Firebase to sync your preferences and access your personalized meal-time setup.

- 🎨 **Beautiful & Fluid UI/UX**  
  Developed exclusively with Flutter, ensuring native-level performance across platforms. A clean, beautiful aesthetic powered by refined typography (`google_fonts`) and modern, responsive design components.

---

## 🛠 Tech Stack

WhatToEat utilizes modern tools and robust architectures to ensure an exceptional experience:

- **Frontend Framework**: [Flutter](https://flutter.dev/) (Dart) - *Cross-platform native performance with rich UI capabilities.*
- **Backend & Database**: [Firebase](https://firebase.google.com/) (Auth, Core, Cloud Firestore) - *Secure, real-time data synchronization.*
- **State Management**: Provider, GetX
- **Location Services**: Geolocator, Permission Handler
- **UI & Animations**: Confetti, Smooth Page Indicator, Iconsax, Cupertino Icons, Google Fonts, Audioplayers
- **Networking/Data**: HTTP, Shared Preferences

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions configured
- An active Firebase Project configured for Android/iOS (ensure to download `google-services.json` / `GoogleService-Info.plist`)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/what_to_eat.git
   cd what_to_eat
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   Ensure `firebase_options.dart` is correctly set up using the [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/).

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📸 Screenshots
*(Coming soon: Add your application screenshots here to showcase the beautiful Home Screen, Spinning Wheels, and Restaurant Finder)*

| Home Dashboard | The Wheel | Restaurant Finder |
| :---: | :---: | :---: |
| <img src="https://via.placeholder.com/250x500?text=Home+Screen" width="200"/> | <img src="https://via.placeholder.com/250x500?text=Manual/Auto+Spin" width="200"/> | <img src="https://via.placeholder.com/250x500?text=Search+%26+Find" width="200"/> |

---

<div align="center">
  <p><b>Made to end decision fatigue. Eat well, live better!</b></p>
</div>
