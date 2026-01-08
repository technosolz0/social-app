import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/theme_constants.dart';
import '../../../data/models/post_model.dart';
import '../../../data/services/api_service.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final String postId;

  const EditPostScreen({super.key, required this.postId});

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  PostModel? _post;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    try {
      final apiService = ApiService();
      final post = await apiService.getPostById(widget.postId);
      setState(() {
        _post = post;
        _captionController.text = post.caption ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load post: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _savePost() async {
    if (_captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Caption cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'PATCH',
        path: '/posts/${widget.postId}/',
        data: {'caption': _captionController.text.trim()},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update post: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_post == null) {
      return const Scaffold(
        body: Center(child: Text('Post not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                  )
                : const Icon(Icons.check, color: Colors.blue),
            onPressed: _isSaving ? null : _savePost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Media Preview (Read-only)
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
                color: Colors.black,
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                _post!.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error, color: Colors.white));
                },
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge),

            // Caption Edit
            TextField(
              controller: _captionController,
              maxLines: 5,
              maxLength: 2200,
              decoration: const InputDecoration(
                labelText: 'Caption',
                hintText: 'Write a caption...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
