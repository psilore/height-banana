import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for CameraService
final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

/// Service for managing camera operations.
///
/// Handles camera initialization, permission requests,
/// image capture, and proper disposal.
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  /// Get the current camera controller
  CameraController? get controller => _controller;

  /// Check if camera is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize camera service and get available cameras
  Future<void> initialize() async {
    try {
      // Get available cameras
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw CameraException(
          'noCameras',
          'No cameras available on this device',
        );
      }

      // Use the back camera by default
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      // Create controller with high resolution for target analysis
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Initialize the controller
      await _controller!.initialize();
      _isInitialized = true;
    } on CameraException catch (e) {
      throw Exception('Camera initialization failed: ${e.description}');
    } on PlatformException catch (e) {
      throw Exception('Permission denied: ${e.message}');
    } catch (e) {
      throw Exception('Failed to initialize camera: $e');
    }
  }

  /// Capture an image from the camera
  ///
  /// Returns the path to the captured image file.
  Future<String> captureImage() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    if (!_controller!.value.isInitialized) {
      throw Exception('Camera controller not ready');
    }

    try {
      // Ensure the camera is not already taking a picture
      if (_controller!.value.isTakingPicture) {
        throw Exception('Camera is already capturing');
      }

      // Capture the image
      final XFile image = await _controller!.takePicture();

      return image.path;
    } on CameraException catch (e) {
      throw Exception('Failed to capture image: ${e.description}');
    } catch (e) {
      throw Exception('Image capture failed: $e');
    }
  }

  /// Switch between front and back cameras
  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      throw Exception('No other cameras available');
    }

    try {
      // Get current camera direction
      final currentDirection = _controller?.description.lensDirection;

      // Find opposite camera
      final newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection != currentDirection,
        orElse: () => _cameras!.first,
      );

      // Dispose current controller
      await dispose();

      // Create new controller
      _controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      // Initialize new controller
      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to switch camera: $e');
    }
  }

  /// Set camera flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (_controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      await _controller!.setFlashMode(mode);
    } catch (e) {
      throw Exception('Failed to set flash mode: $e');
    }
  }

  /// Dispose camera controller and free resources
  Future<void> dispose() async {
    _isInitialized = false;
    await _controller?.dispose();
    _controller = null;
  }

  /// Check if camera permission is granted
  static Future<bool> checkPermission() async {
    try {
      // Try to get available cameras - will fail if permission denied
      await availableCameras();
      return true;
    } catch (e) {
      return false;
    }
  }
}
