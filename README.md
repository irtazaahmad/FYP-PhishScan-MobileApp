# 🚨 PhishScan – AI-Based Phishing Detection System

## 🔐 Detect • Analyze • Protect

PhishScan is an intelligent AI-powered cybersecurity system designed to detect phishing (smishing) messages by analyzing SMS/text content, suspicious URLs, and linguistic patterns. The system classifies messages as **Safe** or **Phishing** in real time using machine learning models.

This project demonstrates a complete end-to-end implementation of **AI in cybersecurity**, combining mobile development and machine learning for real-world threat detection.

---

## 🎓 Academic Context

- 📚 Course: Final Year Project (FYP)  
- 👨‍💻 Author: Muhammad Irtaza Asif  
- 🎯 Domain: Artificial Intelligence + Cybersecurity + Mobile App Development  

---

## 🚀 Key Features

### 🔍 AI-Based Phishing Detection
- Classifies messages as **Phishing** or **Legitimate**
- Uses trained Machine Learning models (Naive Bayes / XGBoost)

### 📩 SMS/Text Analysis
- Analyze incoming or custom messages
- Detect suspicious keywords and patterns

### 🔗 URL Inspection System
- Identifies malicious or suspicious links
- Prevents users from opening unsafe URLs

### ✍️ Manual Message Testing
- Users can input custom messages for instant analysis
- Useful for testing and awareness

### 📊 Result Visualization
- Clean and simple UI results
- Instant prediction output (Safe / Phishing)

### 🔔 Notifications (Optional Feature)
- Alerts for detected phishing messages

---

## 🧠 Technologies Used

### 💻 Frontend (Mobile App)
- Flutter (Dart) – Cross-platform mobile application

### 🤖 Machine Learning
- Python – Model training and preprocessing  
- Naive Bayes – Text classification algorithm  
- XGBoost – High-performance ML model  
- NLP – Text preprocessing, tokenization, feature extraction  

### 🔥 Backend & Database
- Firebase Firestore – Cloud database for storing messages  

### 🌐 Integration
- REST APIs – Model communication (if applicable)

---

## 📱 Application Screens

- Splash Screen  
- Home Dashboard (Analytics + Recent Messages)  
- Messages List Screen  
- Message Detail View  
- Manual Editor (Custom Testing Tool)  
- Settings Screen  

---

## ⚙️ Installation & Setup

- 1. Clone Repository
- 2. Open Terminal
- 3. Run flutter pub get
- 4. Run flutter run

## ⚙️ Firebase Setup

- 1. Navigate to "lib/fcm/firebase_access_token.dart"
- 2. Add your Firebase Service Account credentials