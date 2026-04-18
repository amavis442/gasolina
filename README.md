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
- ✅ **Comprehensive Testing**: 69 passing unit tests

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

### Eerste keer instellen (eenmalig)

De release keystore staat **niet** in git. Je hebt nodig:
- `android/app/gasolina.keystore` — de keystore file
- `android/key.properties` — wachtwoorden

Zorg dat `android/key.properties` er zo uitziet:

```properties
storePassword=<wachtwoord>
keyPassword=<wachtwoord>
keyAlias=gasolina
storeFile=gasolina.keystore
```

> De keystore en wachtwoorden staan in de wachtwoordmanager onder **Gasolina release keystore**.

### APK bouwen

```bash
flutter build apk --release
```

De APK staat daarna op:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Installeren op telefoon (zonder dataverlies)

> ⚠️ **Gebruik NOOIT `flutter install --release`** — de Flutter CLI voert altijd eerst `adb uninstall` uit, waardoor alle app-data gewist wordt (SQLite database, instellingen). Dit is een bekend Flutter-bug (GitHub issue [#96588](https://github.com/flutter/flutter/issues/96588)).

Gebruik in plaats daarvan altijd `adb install -r` direct:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

De `-r` flag vervangt de APK in-place zonder de app eerst te verwijderen — data blijft bewaard.

> **Nooit** de app handmatig verwijderen voor het installeren, want dan ben je alle data kwijt.

### Android Auto Backup (extra veiligheid)

De app is geconfigureerd met Android Auto Backup (`android:allowBackup="true"`). Android back-upt de SQLite database automatisch naar Google Drive (max 25 MB, end-to-end versleuteld). Bij een herinstallatie wordt de data automatisch teruggezet.

### Snelle update in één commando

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
