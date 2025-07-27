import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../providers/app_providers.dart';

class EnhancedScanScreen extends ConsumerStatefulWidget {
  const EnhancedScanScreen({super.key});

  @override
  ConsumerState<EnhancedScanScreen> createState() => _EnhancedScanScreenState();
}

class _EnhancedScanScreenState extends ConsumerState<EnhancedScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String? _error;
  final ImagePicker _imagePicker = ImagePicker();
  String _currentLocation = 'Kigali'; // Default location

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
  }

  Future<void> _initializeCamera() async {
    try {
      // Check and request camera permission
      final cameraPermission = await Permission.camera.status;
      if (cameraPermission != PermissionStatus.granted) {
        final result = await Permission.camera.request();
        if (result != PermissionStatus.granted) {
          setState(() {
            _error = 'Camera permission is required to scan waste items';
          });
          return;
        }
      }

      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        final backCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras![0],
        );
        
        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        
        await _cameraController!.initialize();
        await _cameraController!.setExposureMode(ExposureMode.auto);
        await _cameraController!.setFocusMode(FocusMode.auto);
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        setState(() {
          _error = 'No cameras found on this device';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize camera: ${e.toString()}';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          return; // Use default location
        }
      }

      final position = await Geolocator.getCurrentPosition();
      // In a real app, you'd reverse geocode this to get city name
      // For now, we'll use the default
      setState(() {
        _currentLocation = 'Kigali';
      });
    } catch (e) {
      // Use default location if GPS fails
      print('Location error: $e');
    }
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      setState(() {
        _error = 'Camera is not ready. Please wait for initialization.';
      });
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();

      if (await image.length() > 0) {
        await _processCapturedImage(image.path);
      } else {
        setState(() {
          _error = 'Failed to capture image. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to capture image: ${e.toString()}';
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null && await image.length() > 0) {
        await _processCapturedImage(image.path);
      } else if (image != null) {
        setState(() {
          _error = 'Selected image is empty. Please choose another image.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  Future<void> _processCapturedImage(String imagePath) async {
    // Reset any previous scan processing state
    ref.read(scanProcessingProvider.notifier).reset();
    
    // Navigate to results screen first
    if (mounted) {
      context.push('/scan-results');
      
      // Start processing the scan after navigation
      await ref.read(scanProcessingProvider.notifier).processScan(imagePath, _currentLocation);
    }
  }

  Widget _buildControlButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildCornerIndicator(Alignment alignment) {
    return Positioned(
      top: alignment == Alignment.topLeft || alignment == Alignment.topRight ? -1 : null,
      bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight ? -1 : null,
      left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft ? -1 : null,
      right: alignment == Alignment.topRight || alignment == Alignment.bottomRight ? -1 : null,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
                : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
                : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingOverlay(ScanProcessingState state) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  state.message ?? 'Processing...',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(state.progress * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanProcessingState = ref.watch(scanProcessingProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenRatio = constraints.maxWidth / constraints.maxHeight;
                  final cameraRatio = _cameraController!.value.aspectRatio;
                  
                  double previewWidth, previewHeight;
                  
                  if (screenRatio > cameraRatio) {
                    previewHeight = constraints.maxHeight;
                    previewWidth = previewHeight * cameraRatio;
                  } else {
                    previewWidth = constraints.maxWidth;
                    previewHeight = previewWidth / cameraRatio;
                  }
                  
                  return Center(
                    child: SizedBox(
                      width: previewWidth,
                      height: previewHeight,
                      child: ClipRect(
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  );
                },
              ),
            )
          else if (_error != null)
            _buildErrorState()
          else
            _buildLoadingState(),

          // Processing Overlay
          if (scanProcessingState.isProcessing)
            _buildProcessingOverlay(scanProcessingState),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top + 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Scan Waste Item',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Location indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _currentLocation,
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Instructions
                      const Text(
                        'Position the waste item in the center and tap to capture',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Camera Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gallery Button
                          _buildControlButton(
                            icon: Icons.photo_library,
                            onTap: scanProcessingState.isProcessing ? null : _pickImageFromGallery,
                          ),

                          // Capture Button
                          GestureDetector(
                            onTap: scanProcessingState.isProcessing ? null : _captureImage,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: scanProcessingState.isProcessing
                                    ? Colors.grey.withValues(alpha: 0.5)
                                    : Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: scanProcessingState.isProcessing
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    )
                                  : const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                            ),
                          ),

                          // Flash Toggle
                          _buildControlButton(
                            icon: Icons.flash_off,
                            onTap: () {
                              // TODO: Implement flash toggle
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Camera Focus Indicator
          if (_isCameraInitialized)
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Corner indicators
                      _buildCornerIndicator(Alignment.topLeft),
                      _buildCornerIndicator(Alignment.topRight),
                      _buildCornerIndicator(Alignment.bottomLeft),
                      _buildCornerIndicator(Alignment.bottomRight),
                    ],
                  ),
                ),
              ),
            ),

          // Error Snackbar
          if (_error != null)
            Positioned(
              bottom: 220,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _error = null),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            const Text(
              'Initializing camera...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Camera not available',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializeCamera,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Try Again'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _pickImageFromGallery,
                child: Text(
                  'Choose from Gallery',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
