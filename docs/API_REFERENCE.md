# API Reference

> **Note:** Full API documentation can be generated with `dartdoc`.
> This document provides a high-level overview of the main APIs.

## Table of Contents

- [Domain Models](#domain-models)
- [Repositories](#repositories)
- [Services](#services)
- [Providers](#providers)

---

## Domain Models

### User

```dart
/// Represents an authenticated user
@freezed
class User with _$User {
  const factory User({
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    required DateTime createdAt,
  }) = _User;
}
```

### TrainingSession

```dart
/// Complete training session with metadata and ends
@freezed
class TrainingSession with _$TrainingSession {
  const factory TrainingSession({
    required String id,
    required String userId,
    required DateTime date,
    required String location,
    required String bowType,
    required double distanceMeters,
    required String targetType,
    required List<End> ends,
  }) = _TrainingSession;
  
  // Computed properties
  int get totalScore;
  int get totalArrows;
  double get averageScore;
}
```

### End

```dart
/// Group of arrows (typically 3-6)
@freezed
class End with _$End {
  const factory End({
    required String id,
    required String sessionId,
    required int endNumber,
    required List<Arrow> arrows,
    required DateTime timestamp,
  }) = _End;
  
  int get totalScore;
  double get averageScore;
  int get arrowCount;
}
```

### Arrow

```dart
/// Single arrow with score and coordinates
@freezed
class Arrow with _$Arrow {
  const factory Arrow({
    required String id,
    required String score, // X, 10-1, M
    required double x, // cm from center
    required double y, // cm from center
    required DateTime timestamp,
  }) = _Arrow;
  
  double get distanceFromCenter; // sqrt(x² + y²)
}
```

### TargetFace

```dart
/// Target configuration with scoring zones
@freezed
class TargetFace with _$TargetFace {
  const factory TargetFace({
    required String type, // FITA/WA 122cm, etc.
    required double diameterCm,
    required List<ScoringZone> scoringZones,
  }) = _TargetFace;
  
  factory TargetFace.fita122cm(); // Predefined configurations
  
  String getScoreForDistance(double distanceCm);
}
```

---

## Repositories

### AuthRepository

```dart
abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;
  
  /// Sign in with Google
  Future<User> signInWithGoogle();
  
  /// Sign out
  Future<void> signOut();
  
  /// Get current user
  Future<User?> getCurrentUser();
}
```

### SessionRepository

```dart
abstract class SessionRepository {
  /// Stream of all user sessions
  Stream<List<TrainingSession>> getSessions();
  
  /// Get specific session by ID
  Future<TrainingSession?> getSessionById(String id);
  
  /// Create new session
  Future<void> createSession(TrainingSession session);
  
  /// Update existing session
  Future<void> updateSession(TrainingSession session);
  
  /// Delete session
  Future<void> deleteSession(String id);
}
```

---

## Services

### CameraService

```dart
class CameraService {
  /// Initialize camera with resolution preset
  Future<CameraController> initializeCamera({
    ResolutionPreset resolution = ResolutionPreset.high,
  });
  
  /// Capture image and return file path
  Future<String> captureImage(CameraController controller);
  
  /// Dispose camera controller
  void dispose(CameraController controller);
}
```

### TargetDetectionService

```dart
class TargetDetectionService {
  /// Detect target in image and return center + radius
  Future<TargetInfo> detectTarget(String imagePath);
  
  /// Fallback circle detection method
  Future<TargetInfo> detectTargetWithCircleDetection(String imagePath);
}
```

### ArrowDetectionService

```dart
class ArrowDetectionService {
  /// Detect arrows in target image
  Future<List<DetectedArrow>> detectArrows(
    String imagePath,
    TargetInfo targetInfo,
  );
}
```

### ScoreCalculationService

```dart
class ScoreCalculationService {
  /// Calculate score from arrow position
  String calculateScore({
    required Offset arrowPosition,
    required TargetFace targetFace,
  });
  
  /// Calculate with line-touching detection
  String calculateScoreWithLineDetection({
    required Offset arrowPosition,
    required TargetFace targetFace,
    double touchMarginCm = 0.2,
  });
  
  /// Convert score string to numeric value
  int scoreToNumeric(String score);
}
```

### SyncService

```dart
class SyncService {
  /// Start monitoring connectivity and syncing
  void startSync();
  
  /// Stop sync monitoring
  void stopSync();
  
  /// Force manual sync
  Future<void> forceSync();
}
```

---

## Providers

### Authentication

```dart
/// Auth state stream (User?)
final authStateProvider = StreamProvider<User?>;

/// Current user (AsyncValue<User?>)
final currentUserProvider = FutureProvider<User?>;

/// Auth repository instance
final authRepositoryProvider = Provider<AuthRepository>;
```

### Sessions

```dart
/// All sessions stream
final sessionsStreamProvider = StreamProvider<List<TrainingSession>>;

/// Specific session by ID
final sessionByIdProvider = FutureProvider.family<TrainingSession?, String>;

/// Session repository instance
final sessionRepositoryProvider = Provider<SessionRepository>;
```

### Services

```dart
/// Camera service
final cameraServiceProvider = Provider<CameraService>;

/// Target detection service
final targetDetectionServiceProvider = Provider<TargetDetectionService>;

/// Arrow detection service
final arrowDetectionServiceProvider = Provider<ArrowDetectionService>;

/// Score calculation service
final scoreCalculationServiceProvider = Provider<ScoreCalculationService>;

/// Sync service
final syncServiceProvider = Provider<SyncService>;
```

### Connectivity

```dart
/// Connectivity status stream
final connectivityProvider = StreamProvider<List<ConnectivityResult>>;

/// Is device online? (derived)
final isOnlineProvider = Provider<bool>;
```

---

## Usage Examples

### Create Session

```dart
final repository = ref.read(sessionRepositoryProvider);

final session = TrainingSession(
  id: 'session_${DateTime.now().millisecondsSinceEpoch}',
  userId: currentUser.uid,
  date: DateTime.now(),
  location: 'Local Range',
  bowType: 'Recurve',
  distanceMeters: 18.0,
  targetType: 'FITA 122cm',
  ends: [],
);

await repository.createSession(session);
```

### Watch Sessions

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final sessionsAsync = ref.watch(sessionsStreamProvider);
  
  return sessionsAsync.when(
    data: (sessions) => ListView(
      children: sessions.map((s) => SessionCard(s)).toList(),
    ),
    loading: () => CircularProgressIndicator(),
    error: (err, stack) => Text('Error: $err'),
  );
}
```

### Calculate Score

```dart
final service = ref.read(scoreCalculationServiceProvider);
final target = TargetFace.fita122cm();

final score = service.calculateScore(
  arrowPosition: Offset(2.5, 3.0), // 2.5cm right, 3cm up
  targetFace: target,
);

print('Score: $score'); // "X" or "10" etc.
```

---

## Generating Full Documentation

Generate complete API documentation with dartdoc:

```bash
# Install dartdoc
dart pub global activate dartdoc

# Generate docs
dartdoc

# Open docs (generated in doc/api/)
open doc/api/index.html
```

---

## Further Reading

- **[Architecture Guide](ARCHITECTURE.md)** - System design and patterns
- **[Contributing Guidelines](CONTRIBUTING.md)** - Code style and workflow
- **[Source Code](../lib/)** - Browse annotated source

---

*This API reference covers the main public APIs. See generated dartdoc for complete documentation.*
