# BudgetLens

<p align="center">
  <img src="assets/icon/icon.png" alt="BudgetLens Logo" width="200"/>
</p>

A smart personal budgeting application that helps you manage your finances with a dynamic daily spending allowance.

---

## About The Project

BudgetLens is a mobile application built with Flutter that provides a simple yet effective way to manage your budget. Unlike traditional budgeting apps where you have a fixed daily limit, BudgetLens calculates a dynamic daily spending allowance.

The core idea is to divide your remaining budget by the number of days left in your budget period. This means your daily allowance is automatically adjusted based on your spending habits. If you spend less one day, you'll have more to spend on the following days, and vice versa. This provides a more flexible and realistic approach to budgeting.

All your data is stored locally on your device, ensuring your financial information remains private and secure.

This project was inspired by [Buckwheat](https://github.com/danilkinkin/buckwheat).

---

## Features

- **Dynamic Daily Allowance:** Automatically calculates and updates your daily spending limit.
- **Initial Setup:** A simple setup screen to define your total budget and budget period.
- **Dashboard:** A clear and concise dashboard that displays your key budget information, including your daily allowance and remaining budget.
- **Transaction Logging:** Easily add expenses and income using a user-friendly interface.
- **Transaction History:** View a list of all your past transactions.
- **Local Data Storage:** All your data is stored securely on your device.
- **Dynamic Theming:** The app's color scheme adapts to your system's theme for a native look and feel (on supported platforms).

---

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A code editor like [VS Code](https://code.visualstudio.com/) with the [Flutter extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter).

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/bkk31/budgetlens.git
   ```
2. Navigate to the project directory
   ```sh
   cd budgetlens/budgetlens
   ```
3. Install dependencies
   ```sh
   flutter pub get
   ```
4. Run the app
   ```sh
   flutter run
   ```

---

## Project Structure

The project is structured with a clear separation of concerns, making it easy to understand and maintain.

- `lib/`: Contains the main Dart code for the application.
  - `main.dart`: The entry point of the application.
  - `build_provider.dart`: The central state management hub using the `provider` package.
  - `calculator.dart`: Contains the core budgeting calculation logic.
  - `models.dart`: Defines the data structures for the application.
  - `screens/`: Contains the files for the primary UI screens (Dashboard, Setup, etc.).
  - `widgets/`: Contains reusable UI components.
- `assets/`: Contains the application's assets, such as icons.
- `pubspec.yaml`: Defines the project's dependencies and metadata.

---

## Dependencies

The main dependencies used in this project are:

- `flutter`: The UI framework.
- `provider`: For state management.
- `shared_preferences`: For local data persistence.
- `dynamic_system_colors`: For dynamic UI theming.

---

## License

Distributed under the GNU General Public License v3.0. See `LICENSE` for more information.