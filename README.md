# 📝 Flutter To-Do App with GetX

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-State%20Management-purple?style=for-the-badge)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)

A clean, maintainable, and scalable cross-platform task management application developed using **Flutter**. This project implements the **MVC (Model-View-Controller)** architecture and **GetX** for efficient state management, adhering to **SOLID** principles.

## 📱 Screenshots

| Home (All Tasks) | Create Task | Completed Tasks | Search & Filter |
|:-------------------------:|:-------------------:|:---------------------:|:--------------------:|
| <img width="388" height="819" alt="image" src="https://github.com/user-attachments/assets/84f7c4b0-28ed-4d1b-9ca9-202a2ed04260" /> | <img width="385" height="833" alt="image" src="https://github.com/user-attachments/assets/da07c731-8d57-4e98-9b17-65f4b405ee8b" /> | <img width="394" height="818" alt="image" src="https://github.com/user-attachments/assets/708ce7f5-31d4-43c0-8d1c-3df09f50c31e" /> | <img width="393" height="830" alt="image" src="https://github.com/user-attachments/assets/db5de789-7ec9-453e-948d-80af5c80aed1" /> |

## ✨ Features

* **Task Management (CRUD):** Create, read, update, and delete tasks easily.
* **Status Tracking:** Mark tasks as "Completed" or "Pending" with visual indicators.
* **Persistent Storage:** Data is saved locally on the device using **SQLite**, ensuring data persists across app restarts.
* **Reactive UI:** Real-time interface updates powered by **GetX** observables.
* **Search Functionality:** Quickly find tasks by title.
* **Smart Scheduling:** Set start/end dates and view automatically calculated durations.
* **Responsive Design:** Pixel-perfect layouts optimized for both Android and iOS.

## 🛠️ Tech Stack & Architecture

This project was built with a focus on code quality and scalability.

* **Framework:** Flutter
* **Language:** Dart
* **State Management:** GetX
    * *Chosen for its high performance, minimal boilerplate, and dependency injection capabilities.*
* **Architecture:** MVC (Model-View-Controller)
    * **Model:** Defines data structures and database logic.
    * **View:** Handles UI components and screens.
    * **Controller:** Manages business logic and bridges the Model and View.
* **Local Database:** SQLite (via `sqflite` package)

## 🚀 Getting Started

Follow these steps to run the project locally:

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/MehmetSakirSeker/To-Do-App.git](https://github.com/MehmetSakirSeker/To-Do-App.git)
    cd To-Do-App
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

## 📂 Project Structure

```text
lib/
├── controllers/   # GetX Controllers (Business Logic)
├── models/        # Data Models & Database Helpers
├── views/         # UI Screens & Widgets
├── routes/        # App Routes
└── main.dart      # Entry Point
