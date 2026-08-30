# 💙 "My Progress" — Complete Flutter Application Codebase

The complete **Flutter (Dart)** application for **My Progress** has been generated under `d:\projects\my progress\flutter_app\`.

---

## 📱 Application Code Architecture

```text
d:/projects/my progress/flutter_app/
├── pubspec.yaml                 # Dependencies (shared_preferences, intl, google_fonts)
├── lib/
│   ├── main.dart                # App entry point, Bottom Navigation Shell & Alarm ticker
│   ├── theme/
│   │   └── app_theme.dart       # Dark Green + Light Green + White theme definition
│   ├── utils/
│   │   └── date_utils.dart      # Leap year math, Year progress dot calculations & stats
│   ├── services/
│   │   └── storage_service.dart # Persistent storage for Alarm, DSA counts & Daily Notes
│   ├── screens/
│   │   ├── home_screen.dart     # Present date, Year dots (365/366), Year/Month/Week stats
│   │   ├── alarm_screen.dart    # Time picker, toggle switch, test alarm button
│   │   ├── dsa_screen.dart      # Month selector, Github contribution grid, counter bottom sheet
│   │   └── notes_screen.dart    # Date notes editor, character counter, search & history
│   └── widgets/
│       ├── alarm_modal.dart     # Ringing alarm dialog & paragraph challenge validator
│       └── day_counter_sheet.dart # Bottom sheet modal for adjusting DSA count per date
└── android/
    └── app/src/main/
        └── AndroidManifest.xml # Android permissions and metadata
```

---

## ⚡ How to Run / Build APK from Flutter Project

If you have **Flutter SDK** installed on your machine or another PC:

### 1. Run in Development Mode:
```bash
cd "d:\projects\my progress\flutter_app"
flutter pub get
flutter run
```

### 2. Build Release APK (`app-release.apk`):
```bash
cd "d:\projects\my progress\flutter_app"
flutter build apk --release
```
The compiled APK file will be saved at:
`d:\projects\my progress\flutter_app\build\app\outputs\flutter-apk\app-release.apk`
