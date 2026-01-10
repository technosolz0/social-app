import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img_lib;

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/post_provider.dart';
import '../post/image_editor_screen.dart';

// ============================================
// lib/presentation/screens/camera/camera_screen.dart
// Instagram-like Camera with Filters
// ============================================

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isFrontCamera = true;
  String? _selectedFilter;
  File? _capturedImage;
  XFile? _capturedVideo;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isEmpty) return;

    final camera = _cameras!.firstWhere(
      (c) => c.lensDirection ==
        (_isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          // AR Face Filters would go here (placeholder for now)

          // Top Controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  icon: const Icon(Icons.flash_auto, color: Colors.white),
                  onPressed: _toggleFlash,
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Filter Selection
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: AppConstants.filters.length,
                itemBuilder: (context, index) {
                  final filter = AppConstants.filters[index];
                  final isSelected = _selectedFilter == filter.name;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedFilter = filter.name);
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            filter.icon,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filter.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery
                GestureDetector(
                  onTap: _pickFromGallery,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.white),
                  ),
                ),

                // Capture Button
                GestureDetector(
                  onTap: _capturePhoto,
                  onLongPressStart: (_) => _startVideoRecording(),
                  onLongPressEnd: (_) => _stopVideoRecording(),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Flip Camera
                IconButton(
                  icon: const Icon(
                    Icons.flip_camera_ios,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: _flipCamera,
                ),
              ],
            ),
          ),

          // Recording Timer
          if (_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.fiber_manual_record,
                        color: Colors.white, size: 12),
                      const SizedBox(width: 8),
                      RecordingTimer(),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _capturePhoto() async {
    try {
      final image = await _cameraController!.takePicture();

      // Apply filter
      final filteredImage = await _applyFilter(File(image.path));

      // Navigate to editor
      if (mounted) {
        final result = await Navigator.push<File>(
          context,
          MaterialPageRoute(
            builder: (context) => ImageEditorScreen(
              imageFile: filteredImage,
            ),
          ),
        );

        if (result != null) {
          // Post image
          ref.read(postProvider.notifier).createPost(
            mediaFile: result,
            postType: 'photo',
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _startVideoRecording() async {
    if (_isRecording) return;

    try {
      await _cameraController!.startVideoRecording();
      setState(() => _isRecording = true);
    } catch (e) {
      print('Error starting recording: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (!_isRecording) return;

    try {
      final video = await _cameraController!.stopVideoRecording();
      setState(() => _isRecording = false);

      // Navigate to video editor
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoEditorScreen(
              videoFile: File(video.path),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }

  Future<void> _flipCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await _cameraController?.dispose();
    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    final mode = _cameraController!.value.flashMode;
    await _cameraController!.setFlashMode(
      mode == FlashMode.off ? FlashMode.auto : FlashMode.off,
    );
  }

  Future<File> _applyFilter(File image) async {
    if (_selectedFilter == null) return image;

    final bytes = await image.readAsBytes();
    final img = img_lib.decodeImage(bytes);

    if (img == null) return image;

    // Apply selected filter
    final filtered = await ImageFilters.applyFilter(
      img,
      _selectedFilter!,
    );

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(img_lib.encodeJpg(filtered));

    return file;
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditorScreen(
            imageFile: File(result.path),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}

// Mock classes for demonstration
class RecordingTimer extends StatefulWidget {
  const RecordingTimer({super.key});

  @override
  State<RecordingTimer> createState() => _RecordingTimerState();
}

class _RecordingTimerState extends State<RecordingTimer> {
  @override
  Widget build(BuildContext context) {
    return const Text(
      '00:00',
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }
}



class VideoEditorScreen extends StatelessWidget {
  final File videoFile;

  const VideoEditorScreen({super.key, required this.videoFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Video')),
      body: const Center(
        child: Text('Video Editor'),
      ),
    );
  }
}

class ImageFilters {
  static Future<img_lib.Image> applyFilter(img_lib.Image image, String filterName) async {
    // Mock filter application
    return image;
  }
}

// Mock provider
final postProvider = StateNotifierProvider<PostNotifier, List<dynamic>>(
  (ref) => PostNotifier(),
);

class PostNotifier extends StateNotifier<List<dynamic>> {
  PostNotifier() : super([]);

  void createPost({required File mediaFile, required String postType}) {
    // Mock post creation
  }
}

