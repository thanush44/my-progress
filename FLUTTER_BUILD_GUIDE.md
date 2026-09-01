# 💙 "My Progress" — Complete Flutter Application Codebase

The complete **Flutter (Dart)** application for **My Progress** has been generated under `d:\projects\my progress\flutter_app\`.

---

## 📱 Application Code Architecture

```text
flutter_app/
├── pubspec.yaml                 # Dependencies (shared_preferences, intl, google_fonts, audioplayers, file_picker)
├── assets/
│   └── icon/                    # Master App Icon asset
├── lib/
│   ├── main.dart                # App entry point, Material Theme & Bottom Navigation Shell
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart       # Light & OLED Dark Green theme definitions
│   │   ├── services/
│   │   │   ├── audio_service.dart   # Looped background alarm audio playback engine
│   │   │   └── storage_service.dart # Persistent storage & JSON backup export/import
│   │   └── utils/
│   │       ├── date_utils.dart      # Leap year math, Year progress dot calculations & stats
│   │       └── streak_utils.dart    # Consecutive & longest streak calculation engine
│   └── features/
│       ├── home/
│       │   └── presentation/
│       │       ├── home_screen.dart # Interactive 365/366 day dot grid & stats
│       │       └── widgets/day_snapshot_sheet.dart # Day inspection sheet with DSA & note preview
│       ├── alarm/
│       │   └── presentation/
│       │       ├── alarm_screen.dart # Time picker, ringtone selector & affirmation editor
│       │       └── widgets/alarm_modal.dart # Looped alarm dialog & anti-paste challenge
│       ├── dsa/
│       │   └── presentation/
│       │       ├── dsa_screen.dart   # Streak badges, monthly slider & contribution heat map
│       │       └── widgets/day_counter_sheet.dart # Modal sheet for adjusting problem count
│       └── notes/
│           └── presentation/
│               └── notes_screen.dart # Debounced auto-saving notes & JSON backup modal
├── test/
│   └── unit/                    # Automated unit tests (date math, challenge validation, streaks)
└── android/
    └── app/src/main/
        ├── AndroidManifest.xml # Exact alarm, full-screen intent & wake-lock permissions
        └── res/                 # Adaptive and standard launcher icon mipmaps
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
