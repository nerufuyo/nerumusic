# Neru Music - Project Plan & Implementation Guide

## Project Overview
**Neru Music** is a modern music streaming application built with Flutter and Riverpod, featuring both online streaming and offline playback capabilities with a unique dark-themed UI inspired by modern music platforms.

## Tech Stack
- **Framework**: Flutter (Latest Stable)
- **State Management**: Riverpod
- **Architecture**: Clean Architecture
- **Programming Paradigms**: OOP, DRY, KISS principles
- **APIs**: YouTube Music, Spotify Web API, SoundCloud, Free Music Archive
- **Environment**: Flutter dotenv for sensitive data

## Project Structure
```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── themes/
│   └── utils/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   ├── widgets/
│   ├── providers/
│   └── controllers/
└── main.dart
```

## Strict Project Rules

### 1. Code Quality Standards
- **DRY (Don't Repeat Yourself)**: No code duplication beyond 3 lines
- **KISS (Keep It Simple, Stupid)**: Maximum function complexity of 10 lines
- **OOP**: Proper encapsulation, inheritance, and polymorphism
- **Clean Architecture**: Strict separation of concerns across layers
- **Widget Reusability**: Minimum 80% widget reuse across screens

### 2. Development Standards
- **Code Coverage**: Minimum 85% test coverage
- **Performance**: App startup time under 3 seconds
- **Memory Usage**: Maximum 150MB RAM usage
- **File Size**: Keep widgets under 200 lines
- **Documentation**: Every public method must have dartdoc comments

### 3. Git Commit Rules
- **Format**: `[TYPE]: Brief description of changes`
- **Types**: FEAT, FIX, REFACTOR, TEST, DOCS, STYLE, CHORE
- **Examples**:
  - `FEAT: Add music player widget with basic controls`
  - `FIX: Resolve audio playback issue on Android devices`
  - `REFACTOR: Extract reusable card component from artist screen`
- **No Emojis**: Strictly text-based commit messages
- **Frequency**: Commit after each completed subtask

### 4. UI/UX Standards
- **Design System**: Consistent spacing (8px grid system)
- **Color Palette**: Dark theme with purple/pink accents
- **Typography**: Custom font hierarchy (4 levels max)
- **Animations**: Smooth 300ms transitions
- **Responsiveness**: Support for phones and tablets

## API Integration Strategy

### Primary APIs
1. **YouTube Music API** (Primary source)
2. **Spotify Web API** (Metadata enrichment)
3. **SoundCloud API** (Independent artists)
4. **Free Music Archive** (Open source music)

### API Management Rules
- Implement repository pattern for each API
- Use environment variables for all API keys
- Implement proper error handling and fallbacks
- Cache API responses for offline functionality
- Rate limiting compliance for all APIs

## Phase Implementation Plan

### Phase 1: Project Foundation (Week 1)
**Duration**: 5 days
**Deliverables**:
- Project structure setup
- Clean architecture implementation
- Core utilities and constants
- Environment configuration
- Basic routing setup

**Key Tasks**:
1. Initialize Flutter project with proper folder structure
2. Setup Riverpod state management
3. Configure environment variables (.env file)
4. Implement base repository and use case classes
5. Setup app routing with go_router
6. Create core theme and color schemes
7. Setup dependency injection container

### Phase 2: API Integration Layer (Week 2)
**Duration**: 7 days
**Deliverables**:
- API service implementations
- Data models and entities
- Repository implementations
- Error handling system

**Key Tasks**:
1. Implement YouTube Music API client
2. Create Spotify Web API integration
3. Setup SoundCloud API connection
4. Design and implement data models
5. Create repository implementations with caching
6. Implement network error handling
7. Setup API response caching strategy

### Phase 3: Core Music Features (Week 3-4)
**Duration**: 10 days
**Deliverables**:
- Audio player engine
- Playlist management
- Search functionality
- Basic UI components

**Key Tasks**:
1. Integrate just_audio package for playback
2. Implement audio player controller with Riverpod
3. Create playlist management system
4. Build search functionality across all APIs
5. Implement offline storage with Hive
6. Create reusable UI components (cards, buttons, inputs)
7. Setup audio session management
8. Implement background audio playback

### Phase 4: User Interface Development (Week 5-6)
**Duration**: 10 days
**Deliverables**:
- Complete app UI matching design
- Responsive layouts
- Custom animations
- Reusable widget library

**Key Tasks**:
1. Build home screen with trending content
2. Create artist profile screens
3. Implement music player interface
4. Design playlist and library screens
5. Build search results interface
6. Create login/authentication screens
7. Implement responsive design for tablets
8. Add custom animations and transitions

### Phase 5: Advanced Features (Week 7)
**Duration**: 7 days
**Deliverables**:
- Offline functionality
- User preferences
- Advanced player features
- Performance optimizations

**Key Tasks**:
1. Implement offline music downloads
2. Create user preference system
3. Add equalizer and audio effects
4. Implement sleep timer and crossfade
5. Setup background sync for offline content
6. Optimize app performance and memory usage
7. Implement analytics and crash reporting

### Phase 6: Testing & Deployment (Week 8)
**Duration**: 5 days
**Deliverables**:
- Comprehensive test suite
- Performance optimization
- App store preparation
- Documentation

**Key Tasks**:
1. Write unit tests for all business logic
2. Create widget tests for UI components
3. Implement integration tests
4. Performance testing and optimization
5. Security audit and vulnerability assessment
6. Prepare app store assets and descriptions
7. Final documentation and code review

## Detailed Component Architecture

### 1. Audio Player Core
- **AudioPlayerController**: Main playback controller
- **PlaylistManager**: Queue and playlist management
- **DownloadManager**: Offline content management
- **AudioSessionManager**: Background audio handling

### 2. API Service Layer
- **BaseApiService**: Common API functionality
- **YouTubeMusicService**: YouTube Music integration
- **SpotifyService**: Spotify Web API integration
- **SoundCloudService**: SoundCloud API integration
- **CacheService**: API response caching

### 3. UI Component Library
- **ReusableCard**: Artist/album/track cards
- **CustomButton**: Consistent button styling
- **MusicProgressBar**: Audio progress indicator
- **AnimatedMusicVisualizer**: Visual audio feedback
- **ResponsiveLayout**: Adaptive layout wrapper

### 4. State Management
- **MusicPlayerProvider**: Global player state
- **PlaylistProvider**: Playlist management state
- **UserPreferencesProvider**: User settings state
- **SearchProvider**: Search functionality state
- **DownloadProvider**: Offline content state

## Environment Configuration

### Required Environment Variables
```
# API Keys
YOUTUBE_MUSIC_API_KEY=your_youtube_music_key
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
SOUNDCLOUD_CLIENT_ID=your_soundcloud_client_id

# App Configuration
APP_NAME=Neru Music
API_BASE_URL=https://api.nerumusic.com
SENTRY_DSN=your_sentry_dsn

# Database
CACHE_DURATION=3600
MAX_OFFLINE_SONGS=1000
```

## Quality Assurance Checklist

### Before Each Commit
- [ ] Code follows DRY principles
- [ ] No functions exceed 10 lines
- [ ] All public methods documented
- [ ] Widget reusability maintained
- [ ] Performance impact assessed
- [ ] Tests written and passing

### Before Each Phase Completion
- [ ] All deliverables completed
- [ ] Code review conducted
- [ ] Performance benchmarks met
- [ ] UI matches design specifications
- [ ] Error handling implemented
- [ ] Documentation updated

## Success Metrics
- **Code Quality**: 85%+ test coverage, 0 critical issues
- **Performance**: <3s startup, <150MB RAM usage
- **User Experience**: Smooth 60fps animations, <500ms API responses
- **Maintainability**: 80%+ widget reuse, clean architecture compliance

## Risk Mitigation
1. **API Rate Limits**: Implement caching and fallback strategies
2. **Performance Issues**: Regular profiling and optimization
3. **Design Consistency**: Strict design system enforcement
4. **Technical Debt**: Weekly code review and refactoring sessions

This project plan ensures a systematic approach to building a high-quality music streaming application while maintaining strict development standards and code quality.