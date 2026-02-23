# Kinder World - Educational Flutter App

A comprehensive educational mobile application for children aged 5-12, built with Flutter and featuring AI-powered learning, parental controls, and COPPA/GDPR compliance.

## 🌟 Features

### For Children
- **Educational Content**: Math, Science, Reading, Social Skills, and more
- **Interactive Games**: Fun learning through play
- **AI Buddy**: Personalized AI assistant for learning support
- **Progress Tracking**: XP, levels, streaks, and achievements
- **Offline Mode**: Access content without internet connection

### For Parents
- **Dashboard**: Overview of child's progress and activities
- **Parental Controls**: Screen time limits and content filtering
- **Detailed Reports**: Track learning progress and performance
- **Child Profiles**: Manage multiple children with individual settings
- **Subscription Management**: Upgrade/downgrade family plans

## 🏗 Architecture

### Technical Stack
- **Framework**: Flutter (Dart 3+)
- **State Management**: Riverpod
- **Routing**: Go Router
- **Local Storage**: Hive + Flutter Secure Storage
- **Networking**: Dio with retry logic
- **Charts**: FL Chart
- **Animations**: Lottie

### Project Structure
```
lib/
├── core/
│   ├── constants/          # App constants and configuration
│   ├── localization/       # Internationalization (Arabic/English)
│   ├── models/            # Data models (User, ChildProfile, Activity, etc.)
│   ├── network/           # Network services and API layer
│   ├── storage/           # Local storage (Hive, Secure Storage)
│   ├── theme/             # App theming and colors
│   └── utilities/         # Utility functions
├── features/
│   ├── app_core/          # Splash, onboarding, welcome
│   ├── auth/              # Authentication (parent/child)
│   ├── child_mode/        # Child interface and features
│   ├── parent_mode/       # Parent dashboard and controls
│   ├── ai_buddy/          # AI assistant
│   ├── reports/           # Progress tracking and reports
│   ├── settings/          # App settings
│   └── system_pages/      # Error, maintenance, no internet
├── app.dart               # Main app widget
└── router.dart            # Navigation configuration
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.10.0)
- Dart SDK (>= 3.0.0)
- Android Studio / Xcode

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd kinder_world
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code:
```bash
flutter pub run build_runner build
```

4. Run the app:
```bash
flutter run
```

### Build for Production

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🎯 Performance Targets

The app meets all performance requirements from the SRS:

- ✅ **Startup Time**: < 3 seconds
- ✅ **Content Load Time**: < 2 seconds
- ✅ **AI Response Time**: < 1.5 seconds
- ✅ **Memory Usage**: < 200MB

## 🔒 Security & Compliance

### COPPA Compliance
- Parental consent required for data collection
- Minimal data collection policy
- Age-appropriate content filtering
- Parental control over child data

### GDPR Compliance
- Data anonymization
- Right to deletion
- Privacy controls
- Transparent data usage

### Security Features
- End-to-end encryption
- Secure token storage
- Parental PIN protection
- Regular security audits

## 🌍 Localization

The app supports multiple languages:
- English (EN)
- Arabic (AR)

### Adding New Languages
1. Add translations in `lib/core/localization/l10n/`
2. Update `AppLocalizations` abstract class
3. Add language to supported locales in `app.dart`

## 🎨 Theming

### Child-Friendly Design
- Large touch targets (48px minimum)
- High contrast colors
- Simple navigation
- Voice guidance support

### Theme Modes
- Light Mode (default)
- Dark Mode
- Eye-Friendly Mode (reduced blue light)
- High Contrast Mode

## 🧪 Testing

Run tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test/
```

## 📱 Platform Support

- ✅ iOS 12.0+
- ✅ Android 6.0+ (API 23+)
- ✅ Tablet support
- ✅ Accessibility support

## 🔧 Development

### Code Generation
The project uses code generation for:
- Freezed models (`*.freezed.dart`)
- JSON serialization (`*.g.dart`)
- Riverpod providers

Run code generation:
```bash
flutter pub run build_runner build
```

### Linting
The project uses `flutter_lints` for consistent code style:
```bash
flutter analyze
```

## 📊 Analytics & Monitoring

### Supported Services
- Firebase Analytics (placeholder)
- Firebase Crashlytics (placeholder)
- Custom analytics events

### Performance Monitoring
- Route transition tracking
- API response time monitoring
- Memory usage tracking
- User engagement metrics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod community for state management
- All contributors and testers
- Parents and children who provided feedback

## 📞 Support

For support, please contact:
- Email: support@kinderworld.app
- Documentation: docs.kinderworld.app
- Help Center: help.kinderworld.app

---

**Built with ❤️ for children and families around the world**