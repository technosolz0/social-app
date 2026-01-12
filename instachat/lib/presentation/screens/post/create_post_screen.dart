import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../providers/post_provider.dart';
import '../../providers/activity_tracker_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _selectedImage;
  File? _selectedVideo;
  bool _isLoading = false;
  String _postType = 'photo';

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final storageService = ref.read(storageServiceProvider);
    final image = await storageService.pickImage();
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _selectedVideo = null;
        _postType = 'photo';
      });
    }
  }

  Future<void> _pickVideo() async {
    final storageService = ref.read(storageServiceProvider);
    final video = await storageService.pickVideo();
    if (video != null) {
      setState(() {
        _selectedVideo = video;
        _selectedImage = null;
        _postType = 'video';
      });
    }
  }

  Future<void> _createPost() async {
    if ((_selectedImage == null && _selectedVideo == null) ||
        _captionController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add media and caption')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storageService = ref.read(storageServiceProvider);
      String? mediaUrl;

      if (_selectedImage != null) {
        mediaUrl = await storageService.uploadImage(_selectedImage!);
      } else if (_selectedVideo != null) {
        mediaUrl = await storageService.uploadVideo(_selectedVideo!);
      }

      if (mediaUrl != null) {
        // Extract hashtags from caption
        final hashtags = _extractHashtags(_captionController.text.trim());

        // Create post using provider
        final postProvider = ref.read(postFeedNotifierProvider.notifier);
        final newPost = await postProvider.createPost(
          postType: _postType,
          mediaUrl: mediaUrl,
          caption: _captionController.text.trim(),
          hashtags: hashtags,
        );

        if (mounted) {
          if (newPost != null) {
            // Track activity
            ref
                .read(activityTrackerProvider.notifier)
                .trackPostView(newPost.id);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Post created successfully!')),
            );
            context.go('/home');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to create post')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating post: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<String> _extractHashtags(String text) {
    // Regular expression to match hashtags (words starting with #)
    final hashtagRegex = RegExp(r'#(\w+)');
    final matches = hashtagRegex.allMatches(text);

    // Extract hashtag text without the # symbol
    return matches.map((match) => match.group(1)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Create Post'),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _createPost,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Post', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Media Preview
              if (_selectedImage != null)
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusMedium,
                    ),
                    image: DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else if (_selectedVideo != null)
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusMedium,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                // Media Picker
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusMedium,
                    ),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      const Text(
                        'Add photos or videos',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: AppSizes.paddingMedium),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.photo),
                            label: const Text('Photo'),
                          ),
                          const SizedBox(width: AppSizes.paddingMedium),
                          ElevatedButton.icon(
                            onPressed: _pickVideo,
                            icon: const Icon(Icons.videocam),
                            label: const Text('Video'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: AppSizes.paddingLarge),

              // Caption Input
              Stack(
                children: [
                  TextField(
                    controller: _captionController,
                    maxLines: 5,
                    maxLength: 2200,
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (text) {
                      setState(() {}); // Rebuild to update helpers
                    },
                  ),
                  if (_captionController.text.endsWith('@'))
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 150,
                        color: Colors.white,
                        child: ListView(
                          children: ['user1', 'user2', 'user3'].map((user) {
                            return ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(user),
                              onTap: () {
                                setState(() {
                                  _captionController.text += '$user ';
                                  _captionController
                                      .selection = TextSelection.fromPosition(
                                    TextPosition(
                                      offset: _captionController.text.length,
                                    ),
                                  );
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingMedium),

              // Location Tagging
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Add Location'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement location picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Location picker coming soon'),
                    ),
                  );
                },
              ),

              const Divider(),

              // Advanced Settings
              ExpansionTile(
                title: const Text('Advanced Settings'),
                children: [
                  SwitchListTile(
                    value: true,
                    title: const Text('Turn off commenting'),
                    onChanged: (val) {},
                  ),
                  SwitchListTile(
                    value: false,
                    title: const Text('Hide like count'),
                    onChanged: (val) {},
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.paddingLarge),

              // Post Type Selector
              if (_selectedImage != null || _selectedVideo != null)
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(
                      AppSizes.borderRadiusMedium,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Post Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSizes.paddingSmall),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'photo',
                            groupValue: _postType,
                            onChanged: (value) {
                              setState(() => _postType = value!);
                            },
                          ),
                          const Text('Photo'),
                          const SizedBox(width: AppSizes.paddingLarge),
                          Radio<String>(
                            value: 'video',
                            groupValue: _postType,
                            onChanged: (value) {
                              setState(() => _postType = value!);
                            },
                          ),
                          const Text('Video'),
                          const SizedBox(width: AppSizes.paddingLarge),
                          Radio<String>(
                            value: 'reel',
                            groupValue: _postType,
                            onChanged: (value) {
                              setState(() => _postType = value!);
                            },
                          ),
                          const Text('Reel'),
                        ],
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
}
