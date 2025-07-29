import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../../providers/app_providers.dart';
import '../../../services/logging_service.dart';


class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  String? _error;
  final ImagePicker _imagePicker = ImagePicker();
  String _currentLocation = 'Kigali'; // Default location

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LoggingService.locationInfo('Requesting location permissions...');
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied) {
          LoggingService.locationInfo('Location permission denied');
          return; // Use default location
        }
      }

      LoggingService.locationInfo('Getting current position...');
      final position = await Geolocator.getCurrentPosition();
      LoggingService.locationInfo('Position obtained: $position');
      
      // In a real app, you'd reverse geocode this to get city name
      setState(() {
        _currentLocation = 'Kigali'; // For now, using default
      });
    } catch (e) {
      LoggingService.locationError('Failed to get location', e);
      // Use default location if GPS fails
    }
  }

  Future<void> _initializeCamera() async {
    try {
      LoggingService.cameraInfo('Initializing camera...');
      
      // Handle permissions differently for web and mobile
      if (kIsWeb) {
        // For web, we don't use permission_handler. The browser will handle permissions
        LoggingService.cameraInfo('Running on web, browser will handle permissions');
      } else {
        // Mobile permission handling
        final cameraPermission = await Permission.camera.status;
        if (cameraPermission != PermissionStatus.granted) {
          final result = await Permission.camera.request();
          if (result != PermissionStatus.granted) {
            LoggingService.cameraError('Camera permission denied');
            setState(() {
              _error = 'Camera permission is required to scan waste items';
            });
            return;
          }
        }
      }

      LoggingService.cameraInfo('Getting available cameras...');
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        LoggingService.cameraInfo('Found ${_cameras!.length} cameras');
        // Use the back camera (usually index 0) for better scanning
        final backCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras![0],
        );

        LoggingService.cameraInfo('Initializing camera controller...');
        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();

        // Set exposure and focus modes for better scanning
        await _cameraController!.setExposureMode(ExposureMode.auto);
        await _cameraController!.setFocusMode(FocusMode.auto);

        // Set flash mode to auto for better indoor scanning
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          // Flash might not be available on all devices
          print('Flash not available: $e');
        }

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

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      setState(() {
        _error = 'Camera is not ready. Please wait for initialization.';
      });
      return;
    }

    // Prevent multiple rapid captures
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Add a small delay to ensure camera is ready
      await Future.delayed(const Duration(milliseconds: 100));

      final XFile image = await _cameraController!.takePicture();

      // Verify the image was captured successfully
      if (await image.length() > 0) {
        // Process the captured image through our backend
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (!kIsWeb) {
        // Mobile permission handling
        LoggingService.info('Checking storage permissions...');
        final storageStatus = await Permission.storage.status;
        final photosStatus = await Permission.photos.status;
        
        if (!storageStatus.isGranted || !photosStatus.isGranted) {
          LoggingService.info('Requesting storage permissions...');
          // Request permissions
          final storageResult = await Permission.storage.request();
          final photosResult = await Permission.photos.request();
          
          if (!storageResult.isGranted || !photosResult.isGranted) {
            LoggingService.error('Storage permission denied');
            setState(() {
              _error = 'Storage permission is required to select images from gallery';
            });
            return;
          }
        }
      } else {
        LoggingService.info('Running on web, browser will handle permissions');
      }

      LoggingService.info('Opening image picker...');
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (image != null) {
        LoggingService.info('Image selected successfully');
        final fileSize = await image.length();
        
        LoggingService.debug('Image details:');
        LoggingService.debug('- Path: ${image.path}');
        LoggingService.debug('- File size: $fileSize bytes');

        if (fileSize <= 0) {
          LoggingService.error('Selected image file is empty');
          setState(() {
            _error = 'Selected image appears to be empty. Please choose another image.';
          });
          return;
        }

        // Process the selected image
        LoggingService.info('Processing selected image...');
        await _processCapturedImage(image.path);
      } else {
        LoggingService.info('No image selected (user cancelled)');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _processCapturedImage(String imagePath) async {
    try {
      // Reset any previous scan processing state
      ref.read(scanProcessingProvider.notifier).reset();

      // Navigate to results screen to show processing
      if (mounted) {
        context.push('/scan-results');

        // Start processing the scan after navigation
        await ref
            .read(scanProcessingProvider.notifier)
            .processScan(imagePath, 'Kigali');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to process scan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenRatio =
                      constraints.maxWidth / constraints.maxHeight;
                  final cameraRatio = _cameraController!.value.aspectRatio;

                  // Calculate the optimal size to fill the screen without distortion
                  double previewWidth, previewHeight;

                  if (screenRatio > cameraRatio) {
                    // Screen is wider than camera - fit height and crop width
                    previewHeight = constraints.maxHeight;
                    previewWidth = previewHeight * cameraRatio;
                  } else {
                    // Screen is taller than camera - fit width and crop height
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
                    const SizedBox(width: 48), // Balance the back button
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
                          GestureDetector(
                            onTap: _isLoading ? null : _pickImageFromGallery,
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
                              child: const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),

                          // Capture Button
                          GestureDetector(
                            onTap: _isLoading ? null : _captureImage,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: _isLoading
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
                              child: _isLoading
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

                          // Flash Toggle (placeholder for now)
                          GestureDetector(
                            onTap: () {
                              // TODO: Implement flash toggle
                            },
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
                              child: const Icon(
                                Icons.flash_off,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
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
                      Positioned(
                        top: -1,
                        left: -1,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3),
                              left: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -1,
                        right: -1,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3),
                              right: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -1,
                        left: -1,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3),
                              left: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -1,
                        right: -1,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3),
                              right: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 3),
                            ),
                          ),
                        ),
                      ),
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
