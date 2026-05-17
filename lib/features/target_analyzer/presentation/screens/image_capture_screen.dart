import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/camera_service.dart';

/// Camera capture screen for taking photos of archery targets.
/// Provides live camera preview with target alignment overlay and
/// allows users to capture or select images for arrow detection.
class ImageCaptureScreen extends ConsumerStatefulWidget {
  final String sessionId;
  final String endId;

  const ImageCaptureScreen({
    super.key,
    required this.sessionId,
    required this.endId,
  });

  @override
  ConsumerState<ImageCaptureScreen> createState() => _ImageCaptureScreenState();
}

class _ImageCaptureScreenState extends ConsumerState<ImageCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _errorMessage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final cameraService = ref.read(cameraServiceProvider);
      final controller = await cameraService.initializeCamera(
        resolution: ResolutionPreset.high,
      );

      if (!mounted) return;

      setState(() {
        _cameraController = controller;
        _isInitializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final cameraService = ref.read(cameraServiceProvider);
      final imagePath = await cameraService.captureImage(_cameraController!);

      if (!mounted) return;

      // Navigate to analyzer result screen with captured image
      Navigator.pushReplacementNamed(
        context,
        '/analyzer-result',
        arguments: {
          'imagePath': imagePath,
          'sessionId': widget.sessionId,
          'endId': widget.endId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to capture image: $e';
        _isCapturing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture: $e')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile == null || !mounted) return;

      // Navigate to analyzer result screen with picked image
      Navigator.pushReplacementNamed(
        context,
        '/analyzer-result',
        arguments: {
          'imagePath': pickedFile.path,
          'sessionId': widget.sessionId,
          'endId': widget.endId,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Capture Target',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickFromGallery,
            tooltip: 'Pick from gallery',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeCamera,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pick from Gallery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(
        child: Text(
          'Camera not available',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        Center(
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),

        // Target alignment overlay
        CustomPaint(
          painter: TargetOverlayPainter(),
        ),

        // Capturing indicator
        if (_isCapturing)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Processing image...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery button
            IconButton(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              color: Colors.white70,
              iconSize: 32,
            ),

            // Capture button
            GestureDetector(
              onTap: _isCapturing ? null : _captureImage,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: _isCapturing ? Colors.grey : Colors.transparent,
                ),
                child: _isCapturing
                    ? const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),

            // Info button
            IconButton(
              onPressed: _showCaptureInstructions,
              icon: const Icon(Icons.info_outline),
              color: Colors.white70,
              iconSize: 32,
            ),
          ],
        ),
      ),
    );
  }

  void _showCaptureInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Capture Tips'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📸 Best Practices:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Align target within the circular guide'),
              SizedBox(height: 8),
              Text('• Ensure good lighting (avoid shadows)'),
              SizedBox(height: 8),
              Text('• Keep camera parallel to target face'),
              SizedBox(height: 8),
              Text('• Capture from 2-3 meters away'),
              SizedBox(height: 8),
              Text('• Make sure all arrows are visible'),
              SizedBox(height: 8),
              Text('• Avoid glare on target surface'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for drawing target alignment overlay on camera preview.
class TargetOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final centerPaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Draw main alignment circle
    canvas.drawCircle(center, radius, paint);

    // Draw center crosshair
    canvas.drawLine(
      Offset(center.dx - 20, center.dy),
      Offset(center.dx + 20, center.dy),
      centerPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 20),
      Offset(center.dx, center.dy + 20),
      centerPaint,
    );

    // Draw corner guides
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Top-left
    canvas.drawLine(
      Offset(20, 20),
      Offset(20 + cornerLength, 20),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(20, 20),
      Offset(20, 20 + cornerLength),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - 20, 20),
      Offset(size.width - 20 - cornerLength, 20),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 20, 20),
      Offset(size.width - 20, 20 + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(20, size.height - 20),
      Offset(20 + cornerLength, size.height - 20),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(20, size.height - 20),
      Offset(20, size.height - 20 - cornerLength),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width - 20, size.height - 20),
      Offset(size.width - 20 - cornerLength, size.height - 20),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 20, size.height - 20),
      Offset(size.width - 20, size.height - 20 - cornerLength),
      cornerPaint,
    );

    // Draw instruction text background
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Align target within circle',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Colors.black,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        size.height - 150,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
