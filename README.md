# BudgetLens

<a id="readme-top"></a>

<br />
<div align="center">
  <a href="https://github.com/bkk31/budgetlens">
    <img src="budgetlens/assets/icon/icon.png" alt="Logo" width="120" height="120">
  </a>
  <h3 align="center">BudgetLens</h3>
  <p align="center">
    A smart personal budgeting application with a dynamic daily spending allowance.
    <br />
    <a href="https://github.com/bkk31/budgetlens"><strong>Explore the docs »</strong></a>
    <br /><br />
    <a href="https://github.com/bkk31/budgetlens">View Demo</a>
    &middot;
    <a href="https://github.com/bkk31/budgetlens/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/bkk31/budgetlens/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

## 📖 Table of Contents
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#features">Features</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#project-structure">Project Structure</a></li>
    <li><a href="#dependencies">Dependencies</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## 💡 About The Project

BudgetLens is a mobile budgeting application, built with **Flutter**, designed to help users manage their finances using a **dynamic daily spending allowance**.

Instead of a rigid, fixed daily budget, BudgetLens calculates your allowance by dividing your **remaining budget** by the **number of days left** in the budget cycle. This means:
* **Spend less today** → your allowance automatically increases tomorrow.
* **Spend more today** → your allowance is adjusted downwards for the rest of the period.

This flexible and intuitive approach encourages healthier budgeting habits and provides real-time accountability. All financial data is stored **locally** on your device, ensuring complete **privacy** and user control.

Inspired by Buckwheat.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🛠️ Built With

* ![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) 
* ![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## ✨ Features

* **Dynamic Daily Allowance** – Automatically updated based on remaining funds and days left in the budget cycle.
* **Initial Setup Flow** – Easy guided setup to define your total budget and budgeting period (e.g., monthly).
* **Dashboard** – Clean, intuitive overview providing key budget metrics at a glance.
* **Transaction Logging** – Effortlessly add income or expenses.
* **Transaction History** – Review and track all past entries easily.
* **Local Data Storage** – All financial data is saved securely on your device, ensuring privacy.
* **Dynamic Theming** – Adapts to the device's system theme and colors for a native feel (where supported).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 🚀 Getting Started

Follow these simple instructions to set up and run BudgetLens locally.

### Prerequisites

* **Flutter SDK** → [Installation Guide](https://flutter.dev/docs/get-started/install)
* A code editor like **Visual Studio Code** with the **Flutter extension**.

### Installation

1.  Clone the repository:
    ```bash
    git clone [https://github.com/bkk31/budgetlens.git](https://github.com/bkk31/budgetlens.git)
    ```

2.  Navigate into the project folder:
    ```bash
    cd budgetlens/budgetlens
    ```

3.  Install dependencies:
    ```bash
    flutter pub get
    ```

4.  Run the app on a connected device or emulator:
    ```bash
    flutter run
    ```

5.  (Optional) Build the release APK:
    ```bash
    flutter build apk --release
    ```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## 📂 Project Structure

```bash
budgetlens/
 ├── lib/
 │   ├── main.dart                # App entry point and root widget
 │   ├── build_provider.dart      # State management configuration using Provider
 │   ├── calculator.dart          # Core dynamic budgeting logic and calculations
 │   ├── models.dart              # Data models (e.g., Transaction, Budget)
 │   ├── screens/                 # Major UI screens (Dashboard, Setup, History)
 │   └── widgets/                 # Reusable UI components
 ├── assets/                      # Application assets (icons, images)
 └── pubspec.yaml                 # Dependencies and project metadata
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>
---

## 📦 Dependencies
### Core packages:
 * flutter – The main UI framework.
 * provider – For robust and simple state management across the app.
 * shared_preferences – Used for local, persistent data storage on the device.
 * dynamic_system_colors – Provides support for system-adaptive theming.
<p align="right">(<a href="#readme-top">back to top</a>)</p>
---

## 📜 License
Distributed under the GNU General Public License v3.0. See LICENSE for more details.
<p align="right">(<a href="#readme-top">back to top</a>)</p>
---

### ✉️ Contact
 * Bhargava K K — bkk31
 * Email - bhargavakk13@gmail.com
 * Project Link: https://github.com/bkk31/budgetlens
<p align="right">(<a href="#readme-top">back to top</a>)</p>
---

### 🙏 Acknowledgments
 * Inspired by: https://github.com/danilkinkin/buckwheat
 * The Flutter & Dart teams
 * The Open-source community ❤️
<p align="right">(<a href="#readme-top">back to top</a>)</p>