# HerFlow 🌸

HerFlow is a beautifully designed, offline-first Flutter application empowering women to track their menstrual cycles, daily moods, symptoms, and health metrics directly on their devices. Built with privacy in mind, all data is stored locally.

## ✨ Features

- **Cycle Tracking:** Log period start and end dates along with daily flow intensity.
- **Smart Predictions:** AI-assisted predictive model that uses a Weighted Moving Average to estimate your next cycle length, period duration, and phase (Follicular, Ovulation, Luteal) based on personal history. 
- **Daily Check-ins:** Quickly log your daily mood, physical symptoms, and custom notes.
- **Offline & Private:** All data is kept securely on the device using `shared_preferences`. No external database, no cloud tracking, maximizing user privacy.
- **Dashboards & Visuals:** Easy-to-read calendar views, phase-dependent color styling, and dynamic data visualization.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** `provider` (MVCS Architecture)
- **Local Persistence:** `shared_preferences`
- **UI Components:** `table_calendar` for interactive date picking, `fl_chart` for future data tracking.

### Core Architecture

- **`AppProvider`**: Centralized state manager controlling User Profile, historical logs, and Check-ins. Triggers UI re-renders reactively.
- **`CyclePredictionService`**: Core algorithmic service analyzing variances in cycle logs to establish standard deviation bounds and weighted average predictions.
- **`LocalStorageService`**: Utility handling serialization/deserialization of JSON models for persistent local storage.

---

## 🚀 Getting Started

Follow this comprehensive step-by-step guide to configure the environment, install dependencies, and run HerFlow on your local machine.

### 1. Prerequisites

Before you begin, ensure you have the following installed on your system:
- **[Flutter SDK](https://docs.flutter.dev/get-started/install)** (Version 3.10.7 or higher)
- **[Dart SDK](https://dart.dev/get-dart)** (Comes bundled with Flutter)
- An IDE with Flutter plugins installed:
  - **[Visual Studio Code](https://code.visualstudio.com/)** (Recommended) or
  - **[Android Studio](https://developer.android.com/studio)**
- To compile and run on physical devices or emulators, you will need:
  - For **iOS**: Xcode (macOS only) and CocoaPods.
  - For **Android**: Android Studio, Android SDK, and configured Android Virtual Device (AVD).

### 2. Installation Steps

1. **Clone the repository:**
   Open your terminal and clone the HerFlow repository to your local machine.
   ```bash
   git clone https://github.com/yourusername/HerFlow.git
   ```
2. **Navigate into the project directory:**
   ```bash
   cd HerFlow
   ```
3. **Fetch project dependencies:**
   Run the following command to download all necessary packages defined in `pubspec.yaml`.
   ```bash
   flutter pub get
   ```

### 3. Environment Configuration

Because HerFlow values privacy, it runs entirely offline via local storage. There are currently no API keys, remote databases (like Firebase), or `.env` files required to run the foundational app.

*Note: If backend services or cloud backups are added in the future, copy the sample environment file to `.env` and fill in your keys: `cp .env.example .env`.*

**Ensure your environment doesn't have any trailing cached issues:**
```bash
flutter clean
flutter pub get
```

### 4. Running the Application

You can execute the application in debug mode using either your preferred IDE or the terminal.

**Option A: Using the Terminal**
1. Ensure your emulator is running or a physical device is connected. You can list available devices using:
   ```bash
   flutter devices
   ```
2. Start the application:
   ```bash
   flutter run
   ```
   *(If multiple devices are connected, you can specify one using `flutter run -d <device-id>`)*

**Option B: Using Visual Studio Code**
1. Open the `HerFlow` folder in VS Code.
2. Open `lib/main.dart`.
3. Press `F5` or go to the "Run and Debug" panel to launch the app on your selected device.

---

## 🤝 Contribution Guidelines

We welcome contributions! If you have suggestions for improvements or find a bug, please outline them here.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'feat: Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

**Coding Standards:**
- Ensure all new logic is separated into appropriate services or providers.
- Keep the `provider` state clean and call `notifyListeners()` optimally.
- Run `flutter analyze` ensuring code complies with lints prior to PR.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
