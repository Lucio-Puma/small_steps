# Small Steps 👣
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) ![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white) ![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)

> "A journey of a thousand miles begins with a single step." - Lao Tzu

**Small Steps** is a minimalist mobile application designed to verify and celebrate the small wins in your daily life. In a world obsessed with giant leaps, we focus on the power of consistency and atomic habits to improve mental well-being.

## 📱 Interface Preview

| Empty State | Daily Progress |
|:-----------:|:--------------:|
| ![Empty State Placeholder](assets/screenshots/empty_state.png) | ![List View Placeholder](assets/screenshots/list_view.png) |

*(Place your screenshots here)*

## ✨ Key Features

*   **Daily Tracker**: A clean, distraction-free interface to log your daily achievements.
*   **Visual Progress**: Dynamic progress bar that fills up as you complete tasks, giving immediate positive feedback.
*   **Data Persistence**: Your steps are saved locally on your device using `shared_preferences`. Your data stays with you.
*   **Smart Empty States**: Friendly native UI that encourages you to start the day, without relying on heavy external assets.
*   **QA Mode**: Includes a `Mock Data` generator to quickly populate the list for testing purposes.
*   **Material 3 Design**: Built with the latest Flutter design standards, featuring a calming Turquoise color palette.

## 🛠️ Installation & Setup

Prerequisites: [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your machine.

1.  **Clone the repository**
    ```bash
    git clone https://github.com/yourusername/small_steps.git
    cd small_steps
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the app**
    ```bash
    flutter run
    ```

## 🏗️ Project Structure

This project follows a simple, clean architecture suitable for MVPs:

*   **`lib/main.dart`**: The heart of the application. Contains the UI logic, the `StepItem` data model, and the state management.
*   **Data Storage**: Uses `Shared Preferences` to store user data in JSON format directly on the device, ensuring privacy and offline capability.
*   **No External Assets**: The app uses native Flutter icons (`Checklist`, `Hiking`) to keep the bundle size small and eliminate load errors.

## 🤝 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
*Built with 💙 using Flutter*
