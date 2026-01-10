import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';

class MediaSelectionScreen extends ConsumerStatefulWidget {
  const MediaSelectionScreen({super.key});

  @override
  ConsumerState<MediaSelectionScreen> createState() =>
      _MediaSelectionScreenState();
}

class _MediaSelectionScreenState extends ConsumerState<MediaSelectionScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Create',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: const Text(
                  'What would you like to create?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Options Grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  mainAxisSpacing: AppSizes.paddingMedium,
                  crossAxisSpacing: AppSizes.paddingMedium,
                  children: [
                    _buildOptionCard(
                      icon: Icons.camera_alt,
                      title: 'Camera',
                      subtitle: 'Take a photo',
                      color: Colors.blue,
                      onTap: _openCamera,
                    ),
                    _buildOptionCard(
                      icon: Icons.photo_library,
                      title: 'Gallery',
                      subtitle: 'Choose from gallery',
                      color: Colors.green,
                      onTap: _pickFromGallery,
                    ),
                    _buildOptionCard(
                      icon: Icons.videocam,
                      title: 'Video',
                      subtitle: 'Record a video',
                      color: Colors.red,
                      onTap: _openVideoCamera,
                    ),
                    _buildOptionCard(
                      icon: Icons.video_library,
                      title: 'Video Gallery',
                      subtitle: 'Choose video',
                      color: Colors.purple,
                      onTap: _pickVideoFromGallery,
                    ),
                    _buildOptionCard(
                      icon: Icons.movie_creation,
                      title: 'Reel',
                      subtitle: 'Create a reel',
                      color: Colors.orange,
                      onTap: _createReel,
                    ),
                    _buildOptionCard(
                      icon: Icons.text_fields,
                      title: 'Text Post',
                      subtitle: 'Share your thoughts',
                      color: Colors.teal,
                      onTap: _createTextPost,
                    ),
                  ],
                ),
              ),

              // Recent Media Preview (Optional)
              Container(
                height: 100,
                margin: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5, // Mock recent items
                        itemBuilder: (context, index) {
                          return Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.image,
                              color: Colors.white54,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusLarge),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _openCamera() async {
    // Navigate to camera screen
    Navigator.pop(context); // Close media selection
    context.push('/camera');
  }

  void _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        Navigator.pop(context); // Close media selection
        // Navigate to image editor
        context.push('/edit-image', extra: {'imageFile': File(image.path)});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _openVideoCamera() async {
    Navigator.pop(context); // Close media selection
    context.push('/camera?mode=video');
  }

  void _pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null && mounted) {
        Navigator.pop(context); // Close media selection
        // Navigate to video editor
        context.push('/edit-video', extra: {'videoFile': File(video.path)});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking video: $e')));
      }
    }
  }

  void _createReel() async {
    Navigator.pop(context); // Close media selection
    context.push('/create-reel');
  }

  void _createTextPost() async {
    Navigator.pop(context); // Close media selection
    context.push('/create-post');
  }
}
