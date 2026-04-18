# Gasolina - Fuel Tracking Application

A Flutter application for tracking fuel consumption with clean architecture, TDD approach, and comprehensive charting features.

## Features

- ✅ **Full CRUD for Fuel Entries**: Add, view, edit, and delete fuel entries
- ✅ **Smart Validation**: Input validation with suspicious value warnings
- ✅ **Data Persistence**: SQLite database with proper schema and indexing
- ✅ **Price Trend Chart**: Visualize price per liter over time
- ✅ **Efficiency Chart**: Track fuel efficiency (km/L) trends
- ✅ **Clean Architecture**: Separation of concerns with domain, data, and presentation layers
- ✅ **State Management**: Riverpod for reactive state management
- ✅ **Comprehensive Testing**: 75 passing unit tests

## Architecture

Built with **Clean Architecture** principles following the implementation plan.

## Tech Stack

- **Flutter SDK**: 3.11.4+
- **State Management**: Riverpod 2.6.1
- **Database**: sqflite 2.4.2
- **Charts**: fl_chart 0.68.0
- **Error Handling**: dartz (Either pattern)
- **Testing**: mockito, sqflite_common_ffi

## Getting Started

### Installation

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app in debug mode:
   ```bash
   flutter run
   ```

### Running Tests

```bash
# Run all unit tests (69 tests)
flutter test test/unit/

# Analyze code
flutter analyze
```

## Release Builds & Deploying to Device

### First-time setup (once only)

The release keystore is **not** in git. You need:
- `android/app/gasolina.keystore` — the keystore file
- `android/key.properties` — passwords

Make sure `android/key.properties` looks like this:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=gasolina
storeFile=gasolina.keystore
```

> The keystore and passwords are stored in the password manager under **Gasolina release keystore**.

### Building the APK

```bash
flutter build apk --release
```

The APK is then located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Installing on device (without data loss)

> ⚠️ **NEVER use `flutter install --release`** — the Flutter CLI always runs `adb uninstall` first, which wipes all app data (SQLite database, settings). This is a known Flutter bug (GitHub issue [#96588](https://github.com/flutter/flutter/issues/96588)).

Always use `adb install -r` directly instead:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

The `-r` flag replaces the APK in-place without uninstalling first — data is preserved.

> **Never** manually uninstall the app before installing, as this will delete all data.

### Android Auto Backup (extra safety)

The app is configured with Android Auto Backup (`android:allowBackup="true"`). Android automatically backs up the SQLite database to Google Drive (max 25 MB, end-to-end encrypted). Data is automatically restored on reinstall.

### Quick update in one command

```bash
flutter build apk --release && adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Testing

**Total: 69 passing unit tests** covering:
- Validators and core utilities
- Database operations
- Repository implementation
- Domain entities and use cases
- Data models and serialization

## Author

Built with TDD principles following clean architecture.
