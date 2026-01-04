import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'api_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  final ImagePicker _imagePicker = ImagePicker();
  final ApiService _apiService = ApiService();

  StorageService._internal();

  // ===========================================================================
  // MEDIA PICKING
  // ===========================================================================

  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error picking image: $e');
      }
    }
    return null;
  }

  Future<File?> pickVideo({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error picking video: $e');
      }
    }
    return null;
  }

  // ===========================================================================
  // FILE UPLOAD TO BACKEND
  // ===========================================================================

  Future<String?> uploadImage(File imageFile) async {
    try {
      final downloadUrl = await _apiService.uploadFile(imageFile, type: 'image');

      if (kDebugMode) {
        print('✅ Image uploaded successfully: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading image: $e');
      }
    }
    return null;
  }

  Future<String?> uploadVideo(File videoFile) async {
    try {
      final downloadUrl = await _apiService.uploadFile(videoFile, type: 'video');

      if (kDebugMode) {
        print('✅ Video uploaded successfully: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading video: $e');
      }
    }
    return null;
  }

  Future<String?> uploadFile(File file, {String type = 'file'}) async {
    try {
      final downloadUrl = await _apiService.uploadFile(file, type: type);

      if (kDebugMode) {
        print('✅ File uploaded successfully: $downloadUrl');
      }

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error uploading file: $e');
      }
    }
    return null;
  }

  // ===========================================================================
  // LOCAL FILE MANAGEMENT
  // ===========================================================================

  Future<String> getLocalFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, fileName);
  }

  Future<File> saveFileLocally(File file, String fileName) async {
    final localPath = await getLocalFilePath(fileName);
    return file.copy(localPath);
  }

  Future<bool> deleteLocalFile(String fileName) async {
    try {
      final localPath = await getLocalFilePath(fileName);
      final file = File(localPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting local file: $e');
      }
    }
    return false;
  }

  Future<List<File>> getLocalFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync().whereType<File>();
      return files.toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting local files: $e');
      }
    }
    return [];
  }

  // ===========================================================================
  // CACHE MANAGEMENT
  // ===========================================================================

  Future<void> clearCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = await getApplicationCacheDirectory();

      // Clear temp directory
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
        tempDir.createSync();
      }

      // Clear cache directory
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
        cacheDir.createSync();
      }

      if (kDebugMode) {
        print('🧹 Cache cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing cache: $e');
      }
    }
  }

  Future<String> getCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = await getApplicationCacheDirectory();

      int totalSize = 0;

      // Calculate temp directory size
      if (tempDir.existsSync()) {
        totalSize += _calculateDirectorySize(tempDir);
      }

      // Calculate cache directory size
      if (cacheDir.existsSync()) {
        totalSize += _calculateDirectorySize(cacheDir);
      }

      return _formatBytes(totalSize);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error calculating cache size: $e');
      }
    }
    return '0 B';
  }

  int _calculateDirectorySize(Directory directory) {
    int totalSize = 0;
    try {
      final files = directory.listSync(recursive: true);
      for (final file in files) {
        if (file is File) {
          totalSize += file.lengthSync();
        }
      }
    } catch (e) {
      // Ignore errors
    }
    return totalSize;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  Future<bool> isValidImageFile(File file) async {
    try {
      final bytes = await file.readAsBytes();
      // Check file signature for common image formats
      if (bytes.length < 4) return false;

      // JPEG
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;
      // PNG
      if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) return true;
      // GIF
      if (bytes[0] == 0x47 && bytes[1] == 0x49 && bytes[2] == 0x46) return true;
      // WebP
      if (bytes[0] == 0x52 && bytes[1] == 0x49 && bytes[2] == 0x46 && bytes[3] == 0x46) return true;

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isValidVideoFile(File file) async {
    try {
      final extension = path.extension(file.path).toLowerCase();
      return ['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(extension);
    } catch (e) {
      return false;
    }
  }

  String getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      return _formatBytes(bytes);
    } catch (e) {
      return 'Unknown';
    }
  }
}
