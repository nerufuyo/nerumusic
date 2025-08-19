# 🎵 Neru Music

> A modern, feature-rich music streaming application built with Flutter, featuring advanced audio controls, offline capabilities, and a sleek dark-themed interface.

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.32.7-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Desktop-lightgrey)

</div>

## ✨ Features

### 🎛️ Advanced Audio Controls
- **10-Band Equalizer** with professional presets (Rock, Pop, Jazz, Classical, etc.)
- **Audio Effects**: Bass boost, virtualizer, loudness enhancer, pre-amplifier
- **Sleep Timer** with customizable fade-out and smart pause options
- **Crossfade System** with multiple curve types for seamless track transitions

### 🎵 Music Streaming & Management
- **Multi-API Integration**: YouTube Music, Spotify, SoundCloud, Free Music Archive
- **Smart Search**: Cross-platform music discovery with intelligent results
- **Playlist Management**: Create, edit, and organize your music collections
- **Queue Management**: Advanced playback queue with shuffle and repeat modes

### 📱 Offline Capabilities
- **Download Manager**: Queue-based downloads with progress tracking
- **Storage Optimization**: Smart cache management and storage monitoring
- **Offline Playback**: Full offline music experience with metadata

### 🎨 Modern User Interface
- **Dark Theme**: Sleek, modern interface with purple/pink accents
- **Responsive Design**: Optimized for phones, tablets, and desktop
- **Custom Animations**: Smooth 300ms transitions and interactive elements
- **Adaptive Layouts**: Dynamic UI that adapts to screen size and orientation

### ⚙️ Advanced Features
- **User Preferences**: Comprehensive settings for audio, downloads, and privacy
- **Performance Optimization**: Memory management, caching, and background processing
- **Analytics & Crash Reporting**: Privacy-conscious data collection and error handling
- **Background Playback**: Continuous music playback with audio session management

## 🏗️ Architecture

Built following **Clean Architecture** principles with strict separation of concerns:

```
lib/
├── core/                   # Core utilities and configurations
│   ├── constants/         # App-wide constants and API endpoints
│   ├── errors/           # Error handling and custom exceptions
│   ├── network/          # Network services and HTTP client
│   ├── themes/           # App theming and color schemes
│   ├── services/         # Analytics and shared services
│   ├── utils/            # Utilities and performance optimizers
│   └── animations/       # Custom animations and transitions
├── data/                  # Data layer implementation
│   ├── datasources/      # API integrations and remote data sources
│   ├── models/           # Data models and serialization
│   └── repositories/     # Repository implementations
├── domain/               # Business logic layer
│   ├── entities/         # Core business entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business use cases
├── presentation/         # UI and state management
│   ├── screens/          # App screens and pages
│   ├── widgets/          # Reusable UI components
│   ├── controllers/      # Riverpod state controllers
│   └── navigation/       # App routing and navigation
└── main.dart            # App entry point
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.32.7 or higher
- **Dart**: 3.5 or higher
- **iOS**: Xcode 16.4+ (for iOS development)
- **Android**: Android Studio with SDK 36+
- **CocoaPods**: For iOS dependencies

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/nerufuyo/nerumusic.git
   cd nerumusic
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **iOS Setup** (iOS development only)
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Environment Configuration**
   Create a `.env` file in the root directory:
   ```env
   # API Keys (Optional - Demo data available)
   YOUTUBE_MUSIC_API_KEY=your_youtube_music_key
   SPOTIFY_CLIENT_ID=your_spotify_client_id
   SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
   SOUNDCLOUD_CLIENT_ID=your_soundcloud_client_id
   
   # App Configuration
   APP_NAME=Neru Music
   API_BASE_URL=https://api.nerumusic.com
   ```

5. **Run the application**
   ```bash
   # iOS Simulator
   flutter run -d "iPhone 15 Pro"
   
   # Android Emulator
   flutter run -d android
   
   # Web Browser
   flutter run -d chrome
   
   # Desktop
   flutter run -d macos    # macOS
   flutter run -d windows  # Windows
   flutter run -d linux    # Linux
   ```

## 🛠️ Tech Stack

### Core Technologies
- **[Flutter](https://flutter.dev/)**: Cross-platform UI framework
- **[Dart](https://dart.dev/)**: Programming language
- **[Riverpod](https://riverpod.dev/)**: State management and dependency injection

### Audio & Media
- **[just_audio](https://pub.dev/packages/just_audio)**: Audio playback engine
- **[audio_service](https://pub.dev/packages/audio_service)**: Background audio support
- **[audio_session](https://pub.dev/packages/audio_session)**: Audio session management

### Data & Storage
- **[shared_preferences](https://pub.dev/packages/shared_preferences)**: Local preferences storage
- **[path_provider](https://pub.dev/packages/path_provider)**: File system access
- **[http](https://pub.dev/packages/http)**: HTTP client for API requests

### UI & Navigation
- **[go_router](https://pub.dev/packages/go_router)**: Declarative routing
- **[flutter_animate](https://pub.dev/packages/flutter_animate)**: Animation utilities

### Development Tools
- **[flutter_lints](https://pub.dev/packages/flutter_lints)**: Dart/Flutter linting
- **[build_runner](https://pub.dev/packages/build_runner)**: Code generation
- **[freezed](https://pub.dev/packages/freezed)**: Immutable data classes

## 📱 Platform Support

| Platform | Status | Features |
|----------|--------|----------|
| **iOS** | ✅ Full Support | Background playback, equalizer, offline downloads |
| **Android** | ✅ Full Support | Background playback, equalizer, offline downloads |
| **Web** | ✅ Full Support | Streaming, playlists, responsive design |
| **macOS** | ✅ Full Support | Desktop-optimized UI, keyboard shortcuts |
| **Windows** | ⚠️ Beta | Basic functionality, ongoing optimization |
| **Linux** | ⚠️ Beta | Basic functionality, ongoing optimization |

## 🎯 Performance

### Benchmarks
- **App Startup**: < 3 seconds
- **Memory Usage**: < 150MB RAM
- **Audio Latency**: < 50ms
- **Search Response**: < 500ms
- **UI Framerate**: 60fps consistent

### Optimizations
- **Lazy Loading**: Components load on-demand
- **Image Caching**: LRU cache with automatic cleanup
- **Background Processing**: Heavy operations in isolates
- **Memory Management**: Smart cache eviction and garbage collection

## 🧪 Testing

Run the test suite:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Test coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**Current Coverage**: 85%+ across all modules

## 🔧 Development

### Code Quality Standards
- **DRY Principle**: No code duplication beyond 3 lines
- **KISS Principle**: Maximum function complexity of 10 lines
- **Clean Architecture**: Strict separation of concerns
- **Widget Reusability**: 80%+ reuse across screens

### Git Workflow
```bash
# Commit format
git commit -m "feat: Add equalizer presets for enhanced audio experience"
git commit -m "fix: Resolve audio playback issue on Android devices"
git commit -m "refactor: Extract reusable card component"
```

### Build & Release
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS Archive
flutter build ipa --release

# Web
flutter build web --release

# Desktop
flutter build macos --release
flutter build windows --release
flutter build linux --release
```

## 📊 Analytics & Privacy

- **Privacy-First**: All analytics are optional and user-controlled
- **Crash Reporting**: Automatic error detection with user consent
- **Usage Analytics**: Anonymous usage patterns to improve UX
- **Data Protection**: No personal data stored without explicit consent

## 🤝 Contributing

We welcome contributions! Please see our [Project Plan](neru_music_project_plan.md) for detailed development guidelines.

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Follow our coding standards and commit conventions
4. Ensure tests pass and coverage is maintained
5. Submit a pull request with detailed description

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Riverpod Community** for excellent state management
- **Audio Plugin Authors** for robust audio solutions
- **Open Source Music APIs** for enabling music discovery
- **Design Inspiration** from modern music streaming platforms

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/nerufuyo/nerumusic/issues)
- **Discussions**: [GitHub Discussions](https://github.com/nerufuyo/nerumusic/discussions)
- **Documentation**: [Project Plan](neru_music_project_plan.md)

---

<div align="center">

**Built with ❤️ using Flutter**

[⭐ Star this repo](https://github.com/nerufuyo/nerumusic) if you find it helpful!

</div>
