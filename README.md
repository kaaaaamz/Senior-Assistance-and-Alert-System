# 🩺 Senior Assistance and Alert System

A real-time health monitoring Flutter app powered by Firebase and ESP32 sensors. This system is designed to help **seniors**, **caregivers**, and **doctors** stay connected and informed about vital signs and emergency conditions.

## 📱 Features

### 👴 Seniors / Patients
- View **real-time BPM (heart rate)** and **SpO2 (oxygen saturation)**.
- Create **medication reminders** that appear on the home screen.
- View **current location** on an interactive map.
- Access a list of linked **doctors** and **caregivers**.

### 🧑‍⚕️ Doctors
- Monitor real-time **BPM** and **SpO2** of their patients.
- Set custom **thresholds** for each patient.
- Receive **alerts** when a patient's vitals are outside the safe range.
- View the **location** of patients in distress, with the **fastest route** to reach them.
- Access **daily statistics** of patient vitals (historical BPM and SpO2 trends).

### 👩‍💼 Caregivers
- Monitor vitals of the patients they’re assigned to.
- Receive notifications when alerts are triggered by abnormal health readings.

---

## 🛠️ Tech Stack

- **Flutter** — Cross-platform mobile development
- **Firebase Authentication** — Secure user management
- **Firebase Realtime Database** — Live data sync of vitals and user information
- **Google Maps** — Live location tracking and directions
- **ESP32** + **BPM & SpO2 Sensors** — Real-time health data transmission via Wi-Fi

---

## 🔄 How It Works

1. The **ESP32** collects **BPM** and **SpO2** using health sensors.
2. Data is sent in real-time to **Firebase Realtime Database**.
3. The **Flutter app** fetches this data and displays it in real-time for users.
4. If a patient's vitals go out of the doctor-defined threshold:
   - A **notification** is sent to both doctor and caregiver.
   - The **location** of the patient is shown, with directions to reach them.
5. Daily **statistics** are generated to track health trends.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- Firebase Project Setup
- ESP32 configured with Wi-Fi and sensor integration

### Clone the repository
```bash
git clone https://github.com/kaaaaamz/Senior-Assistance-and-Alert-System.git
cd Senior-Assistance-and-Alert-System
