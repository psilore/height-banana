# Architecture Overview

## System Architecture

Height Banana follows **Clean Architecture** principles with three distinct layers:

```
┌─────────────────────────────────────────────────────┐
│                 Presentation Layer                   │
│  (UI Screens + Riverpod State Providers)            │
│  • Stateless/Stateful Widgets                       │
│  • Riverpod Providers for state management          │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│                  Domain Layer                        │
│  (Business Logic + Entities)                        │
│  • Models (Freezed immutable classes)               │
│  • Repository interfaces                            │
│  • Pure business logic (no Flutter dependencies)    │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│                   Data Layer                         │
│  (Repository Implementations + Data Sources)         │
│  • Firebase/Firestore integration                   │
│  • Hive local storage                               │
│  • ML Kit computer vision services                  │
└─────────────────────────────────────────────────────┘
```

## Key Architectural Patterns

### 1. Clean Architecture
- **Domain** layer has zero external dependencies
- Business logic is testable without Flutter framework
- Repository pattern abstracts data sources

### 2. Offline-First Architecture
```
Write Path:  UI → Repository → [Firestore + Hive]
Read Path:   UI → Repository → Hive (fast) → Firestore (fallback)
```

### 3. State Management (Riverpod)
- Providers expose reactive streams
- UI rebuilds automatically on state changes
- Type-safe dependency injection

## Detailed Layer Breakdown

### Presentation Layer

**Responsibilities:**
- Display UI
- Handle user interactions
- Consume state from providers
- Trigger business logic

**Components:**
- `screens/` - Full-page views
- `widgets/` - Reusable UI components
- `providers/` - Riverpod state providers

**Example Flow:**
```dart
LoginScreen → authStateProvider → FirebaseAuthRepository
```

### Domain Layer

**Responsibilities:**
- Define business entities
- Declare repository contracts
- Contain pure business logic

**Models (Freezed):**
- `User` - Authentication data
- `TrainingSession` - Complete training session
- `End` - Group of 3-6 arrows
- `Arrow` - Single arrow with score & coordinates
- `TargetFace` - Scoring configuration

**Characteristics:**
- Immutable (via Freezed)
- Serializable (JSON)
- No Flutter dependencies
- 100% testable

### Data Layer

**Repositories:**
- `AuthRepository` - User authentication
- `SessionRepository` - Training session CRUD

**Data Sources:**
- Firebase Auth + Google Sign-In
- Cloud Firestore (cloud sync)
- Hive (offline cache)
- ML Kit (computer vision)

**Offline-First Strategy:**
```dart
Future<void> createSession(TrainingSession session) async {
  // Write to both sources
  await _firestore.add(session);
  await _hive.put(session);
}

Stream<List<TrainingSession>> getSessions() {
  // Read from cache first, then sync
  return _hive.watchSessions().asyncMap((cached) async {
    final fresh = await _firestore.getSessions();
    _hive.updateCache(fresh); // Update cache in background
    return fresh;
  });
}
```

## Data Flow Examples

### 1. User Login
```
LoginScreen
  └→ authStateProvider.signInWithGoogle()
       └→ FirebaseAuthRepository.signInWithGoogle()
            ├→ GoogleSignIn.signIn()
            └→ FirebaseAuth.signInWithCredential()
                 └→ Firestore.collection('user_profiles').set()
```

### 2. Create Training Session
```
SessionCreateScreen (form input)
  └→ sessionRepositoryProvider.createSession()
       └→ SessionRepositoryImpl.createSession()
            ├→ Firestore.add(session) [cloud]
            └→ Hive.put(session) [local cache]
```

### 3. Capture & Analyze Target
```
ImageCaptureScreen
  └→ CameraService.captureImage()
       └→ AnalyzerResultScreen
            ├→ TargetDetectionService.detectTarget()
            ├→ ArrowDetectionService.detectArrows()
            └→ ScoreCalculationService.calculateScores()
                 └→ EndLoggerScreen (save to session)
```

## State Management (Riverpod)

### Provider Types

**StreamProvider** - Reactive data streams
```dart
final sessionsStreamProvider = StreamProvider<List<TrainingSession>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getSessions();
});
```

**FutureProvider** - Async operations
```dart
final sessionByIdProvider = FutureProvider.family<TrainingSession, String>((ref, id) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.getSessionById(id);
});
```

**Provider** - Singleton services
```dart
final cameraServiceProvider = Provider((ref) => CameraService());
```

### Dependency Injection
```dart
// main.dart
runApp(
  ProviderScope(
    child: MyApp(),
  ),
);

// Any screen can access:
final sessions = ref.watch(sessionsStreamProvider);
```

## Computer Vision Pipeline

```
1. Image Capture
   └→ CameraService.captureImage()

2. Target Detection
   └→ ML Kit ObjectDetection
        └→ Find target boundaries, center point

3. Arrow Detection
   └→ Edge detection + circle/line finding
        └→ Identify arrow impact points

4. Coordinate Mapping
   └→ Pixel coords → Normalized cm coords

5. Score Calculation
   └→ Distance from center → Scoring zone
        └→ Apply line-touching rule
```

## Security Architecture

### Authentication
- Google OAuth 2.0
- Firebase Authentication
- JWT tokens (managed by Firebase)

### Data Isolation
```javascript
// Firestore Security Rules
match /training_sessions/{sessionId} {
  allow read, write: if request.auth.uid == resource.data.userId;
}
```

### Secrets Management
- Firebase configs NOT committed
- Debug keystore generated per-dev
- Production keystore in GitHub Secrets

## Performance Optimizations

### 1. Offline-First
- Local cache (Hive) for instant reads
- Background sync with Firestore
- Works without internet

### 2. Code Generation
- Freezed for immutable classes
- JSON serialization
- Reduces boilerplate & errors

### 3. Lazy Loading
- Providers only initialized when needed
- Riverpod auto-disposes unused providers

### 4. Image Processing
- Runs in separate isolate
- Doesn't block UI thread
- High-res capture, efficient ML inference

## Testing Strategy

### Unit Tests
- Domain models (Arrow, End, Session)
- Score calculation logic
- Repository business logic
- 100% coverage on critical paths

### Widget Tests
- Screen rendering
- User interactions
- State changes

### Integration Tests
- Full flows (login → create session → capture → score)
- Firebase emulator for backend

## Folder Structure

```
lib/
├── app/
│   ├── app.dart              # Root widget
│   ├── router/               # Navigation
│   └── theme/                # Material theme
├── core/
│   ├── constants/            # App-wide constants
│   ├── services/             # Shared services
│   └── storage/              # Hive setup
└── features/
    ├── auth/
    │   ├── domain/           # User model, interfaces
    │   ├── data/             # Firebase implementation
    │   └── presentation/     # Login/Profile screens
    ├── session_logger/
    │   ├── domain/           # Session, End, Arrow models
    │   ├── data/             # Firestore + Hive repos
    │   └── presentation/     # Session CRUD screens
    ├── target_analyzer/
    │   ├── domain/           # DetectedArrow model
    │   ├── data/             # ML Kit services
    │   └── presentation/     # Camera, analyzer screens
    └── statistics/
        └── presentation/     # Charts, heatmaps
```

## Technology Choices

| Need | Technology | Rationale |
|------|-----------|-----------|
| **UI Framework** | Flutter | Cross-platform, native performance |
| **State** | Riverpod | Type-safe, compile-time DI |
| **Auth** | Firebase Auth | Battle-tested, Google Sign-In |
| **Database** | Firestore | Real-time sync, offline support |
| **Local Storage** | Hive | Fast, no SQL needed |
| **Computer Vision** | Google ML Kit | On-device, privacy-friendly |
| **Immutability** | Freezed | Code generation, less bugs |
| **DI** | Riverpod Providers | Testable, no boilerplate |

## Scalability Considerations

### Horizontal Scaling
- Firestore auto-scales
- Stateless architecture
- Cloud Functions for heavy compute (future)

### Performance
- Hive cache limits memory usage
- Pagination for large session lists
- Image compression before ML processing

### Future Enhancements
- **Cloud Storage** - Store target photos
- **Cloud Functions** - Server-side ML inference
- **Push Notifications** - Training reminders
- **Social Features** - Share sessions with coaches

---

**Architecture designed for:**
- ✅ Testability
- ✅ Maintainability
- ✅ Scalability
- ✅ Offline-first UX
- ✅ Clean code organization
