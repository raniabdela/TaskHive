# 🐝 TaskHive – Smart Team Task Management App

TaskHive is a Flutter-based mobile application designed to help teams organize projects, manage tasks, and collaborate efficiently. It provides a clean and simple interface for tracking work progress, assigning tasks, and communicating through task-based comments.

---

## 📱 Features

- User authentication (Sign up, Login, Logout)
- Create and manage multiple projects
- Add, update, and track tasks within projects
- Task organization (To Do, In Progress, Done)
- Task comments for team communication
- Dashboard with task statistics and recent activity
- Profile management system
- Search and filter tasks
- Real-time updates using Firebase.

---
## 🧭 App Navigation

After login, users access a bottom navigation system with four main sections:

- Dashboard (overview of tasks and progress)
- Projects (list of all projects)
- Tasks (all tasks across projects)
- Profile (user account details)

---

## 🗄 Backend

The app uses Firebase services:

- Firebase Authentication (user login & signup)
- Firebase Firestore (data storage)
- Firebase Storage (for profile images)

### Firestore Structure

- users
- projects
- tasks
  - subcollection: comments

Each task belongs to a project and can have multiple comments for collaboration.
---

## 🔧 Tech Stack

- Flutter (Dart)
- Firebase Authentication
- Firebase Firestore
- Firebase Storage 
- Material Design UI

---

## 🚀 Getting Started

### 1. Clone the repository

git clone https://github.com/raniabdela/taskhive.git

### 2. Install dependencies

flutter pub get

### 3. Connect Firebase
- Add google-services.json for Android
- Configure Firebase project in Flutter

### 4. Run the app

flutter run

---

## 👨‍💻 Authors

Group Project – Flutter Course
Developed by: @raniabdela

---

## 📄 License

This project is for educational purposes only.

