import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';

class ReportBottomSheet extends StatefulWidget {
  final String contentType; // 'post', 'comment', 'user'
  final String contentId;

  const ReportBottomSheet({
    super.key,
    required this.contentType,
    required this.contentId,
  });

  static void show(BuildContext context, String contentType, String contentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ReportBottomSheet(contentType: contentType, contentId: contentId),
    );
  }

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'spam';
  bool _isLoading = false;

  final Map<String, String> _categories = {
    'spam': 'Spam',
    'harassment': 'Harassment or Bullying',
    'inappropriate': 'Inappropriate Content',
    'misinformation': 'Misinformation',
    'other': 'Other',
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      await apiService.customRequest(
        method: 'POST',
        path: '/reports/',
        data: {
          'content_type': widget.contentType,
          'object_id': widget.contentId,
          'category': _selectedCategory,
          'description': _descriptionController.text,
        },
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit report: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Report Content',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            'Why are you reporting this?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _categories.entries.map((e) {
              return DropdownMenuItem(value: e.key, child: Text(e.value));
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCategory = value);
            },
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Additional Details (Optional)',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Submit Report'),
          ),
        ],
      ),
    );
  }
}
