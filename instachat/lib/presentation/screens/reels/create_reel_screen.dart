import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/services/storage_service.dart';
import '../../providers/post_provider.dart';
import 'reel_editor_screen.dart';

class CreateReelScreen extends ConsumerWidget {
  const CreateReelScreen({super.key});

  Future<void> _pickVideo(BuildContext context, WidgetRef ref, bool fromCamera) async {
    final storageService = ref.read(storageServiceProvider);
    
    // Using pickVideo which typically handles gallery. 
    // For camera, we'd need ImagePicker().pickVideo(source: ImageSource.camera)
    // Assuming storageService has appropriate methods or we use ImagePicker directly here for simplicity/completeness
    
    // Since we don't know the exact implementation of storageService.pickVideo (it might just open gallery),
    // let's use the camera route or gallery picker.
    
    // Ideally we navigate to our custom CameraScreen for recording, 
    // but here we are implementing the "Create Reel" selection screen.
    
    if (fromCamera) {
      // Navigate to existing camera screen
      context.push('/camera');
    } else {
      final videoFile = await storageService.pickVideo();
      if (videoFile != null) {
        if (context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ReelEditorScreen(videoFile: videoFile),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Reel')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.movie_creation_outlined, size: 80, color: Colors.pink),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _pickVideo(context, ref, true),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Camera'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _pickVideo(context, ref, false),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
