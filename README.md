# PhonePe_Replicated_Project
This project is a PhonePe-inspired Flutter interface with interactive, local-only demo flows. It does not connect to real payment or banking services.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Screenshots](#screenshots)

## Introduction

This project recreates a dark PhonePe-inspired mobile interface in Flutter. Its bottom navigation follows the supplied reference: Home, Search, QR, Alerts, and History.

## Features

- Scrollable Home services and offers
- Animated gold-banner coins and a replayable, capped demo coin counter (visual only; no real rewards or value)
- Search suggestions and filterable shortcuts
- Live QR scanning and a demo QR preview
- Dismissible alerts and searchable payment history
- Send-money, bank selection, balance, wallet, and payment-success demo flows
- Dark styling and a central QR bottom-navigation action

Note: QR scanning uses the live camera and requires camera permission. In a phone browser the page must be served from HTTPS (localhost is also allowed); plain HTTP from a PC's LAN address cannot access the camera. QR images can also be selected from the gallery on web and Android. The web camera decoder is bundled locally, so it does not need to fetch its scanner runtime from a CDN. Decoded text is shown even if the review API is unavailable. When available, the local review API only parses UPI fields; it does not verify an account or initiate a payment. Torch availability depends on the selected camera and device; unsupported cameras are indicated in the scanner. The payment-success receipt is a visual demo marked as such; it does not represent a real transfer. Bank linking, balance checks, wallet activation, and payments do not contact financial services.

## Local QR review backend

The scanner uses a small Dart HTTP service to parse UPI QR details. It is read-only and does not connect to a bank, verify that a UPI ID exists, store scan history, or move money.

1. Start the backend from the project root:
   ```sh
   dart run tool/qr_backend.dart
   ```
   It listens on `http://127.0.0.1:8081` by default. Check that it is ready at `http://127.0.0.1:8081/api/health`.
2. In another terminal, run the web app:
   ```sh
   flutter run -d chrome --dart-define=QR_BACKEND_URL=http://localhost:8081
   ```
   Android emulators use `http://10.0.2.2:8081` by default. Start the backend with `dart run tool/qr_backend.dart --host=0.0.0.0` so the emulator can reach the host machine. For a physical Android device, use the same host option and run Flutter with `--dart-define=QR_BACKEND_URL=http://<YOUR-PC-LAN-IP>:8081`. Do not expose this development service to the public internet.

The endpoint is `POST /api/qr/resolve` with JSON `{"qrPayload":"upi://pay?pa=merchant%40bank"}`. It returns a structured `resolved`, `unsupported`, or `invalid` result. Local HTTP is enabled only in Android debug builds; use HTTPS and an official provider backend for any production integration.

## Installation

1. **Clone the repository**
   ```sh
   git clone https://github.com/RajalakshmiR24/PhonePe_Replicated_Project.git
   cd PhonePe_Replicated_Project
   ```

2. **Install dependencies**
   ```sh
   flutter pub get
   ```

3. **Run the application**
   ```sh
   flutter run
   ```

## Usage

After installation, run the app on an emulator, physical device, or Flutter Web. Use the bottom navigation to switch between all five screens.

## Screenshots

### Home Screen
![Home Screen](screenshots/home.png)

### Payments Screen
![Payments Screen](screenshots/payments.png)

### Offers Screen
![Offers Screen](screenshots/offers.png)

### My Money Screen
![My Money Screen](screenshots/my_money.png)

### Profile Screen
![Profile Screen](screenshots/profile.png)


---

Happy coding! If you have any questions, feel free to reach out.
