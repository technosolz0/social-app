import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

// Provider for editor state
final imageEditorProvider =
    StateNotifierProvider<ImageEditorNotifier, ImageEditorState>((ref) {
      return ImageEditorNotifier();
    });

// Models for overlays
class TextOverlay {
  final String id;
  final String text;
  final Offset position;
  final double scale;
  final double rotation;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final String fontFamily;

  const TextOverlay({
    required this.id,
    required this.text,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.color = Colors.white,
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.normal,
    this.fontFamily = 'Roboto',
  });

  TextOverlay copyWith({
    String? id,
    String? text,
    Offset? position,
    double? scale,
    double? rotation,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    String? fontFamily,
  }) {
    return TextOverlay(
      id: id ?? this.id,
      text: text ?? this.text,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      color: color ?? this.color,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class StickerOverlay {
  final String id;
  final String emoji;
  final Offset position;
  final double scale;
  final double rotation;

  const StickerOverlay({
    required this.id,
    required this.emoji,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  StickerOverlay copyWith({
    String? id,
    String? emoji,
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    return StickerOverlay(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }
}

class ImageFilter {
  final String name;
  final List<double> matrix;

  const ImageFilter({required this.name, required this.matrix});
}

class ImageEditorState {
  final double brightness;
  final double contrast;
  final double saturation;
  final double rotation;
  final String caption;
  final List<String> hashtags;
  final bool isLoading;
  final List<TextOverlay> textOverlays;
  final List<StickerOverlay> stickerOverlays;
  final ImageFilter? selectedFilter;
  final Rect? cropRect;
  final File? processedImage;

  const ImageEditorState({
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.rotation = 0.0,
    this.caption = '',
    this.hashtags = const [],
    this.isLoading = false,
    this.textOverlays = const [],
    this.stickerOverlays = const [],
    this.selectedFilter,
    this.cropRect,
    this.processedImage,
  });

  ImageEditorState copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? rotation,
    String? caption,
    List<String>? hashtags,
    bool? isLoading,
    List<TextOverlay>? textOverlays,
    List<StickerOverlay>? stickerOverlays,
    ImageFilter? selectedFilter,
    Rect? cropRect,
    File? processedImage,
  }) {
    return ImageEditorState(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      rotation: rotation ?? this.rotation,
      caption: caption ?? this.caption,
      hashtags: hashtags ?? this.hashtags,
      isLoading: isLoading ?? this.isLoading,
      textOverlays: textOverlays ?? this.textOverlays,
      stickerOverlays: stickerOverlays ?? this.stickerOverlays,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      cropRect: cropRect ?? this.cropRect,
      processedImage: processedImage ?? this.processedImage,
    );
  }
}

class ImageEditorNotifier extends StateNotifier<ImageEditorState> {
  ImageEditorNotifier() : super(const ImageEditorState());

  void updateBrightness(double value) {
    state = state.copyWith(brightness: value);
  }

  void updateContrast(double value) {
    state = state.copyWith(contrast: value);
  }

  void updateSaturation(double value) {
    state = state.copyWith(saturation: value);
  }

  void updateRotation(double value) {
    state = state.copyWith(rotation: value);
  }

  void updateCaption(String value) {
    state = state.copyWith(caption: value);
  }

  void addHashtag(String tag) {
    final newHashtags = [...state.hashtags, tag];
    state = state.copyWith(hashtags: newHashtags);
  }

  void removeHashtag(String tag) {
    final newHashtags = state.hashtags.where((t) => t != tag).toList();
    state = state.copyWith(hashtags: newHashtags);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void resetAdjustments() {
    state = state.copyWith(
      brightness: 0.0,
      contrast: 1.0,
      saturation: 1.0,
      rotation: 0.0,
    );
  }

  void addTextOverlay(TextOverlay overlay) {
    final newOverlays = [...state.textOverlays, overlay];
    state = state.copyWith(textOverlays: newOverlays);
  }

  void updateTextOverlay(String id, TextOverlay updatedOverlay) {
    final newOverlays = state.textOverlays
        .map((overlay) => overlay.id == id ? updatedOverlay : overlay)
        .toList();
    state = state.copyWith(textOverlays: newOverlays);
  }

  void removeTextOverlay(String id) {
    final newOverlays = state.textOverlays
        .where((overlay) => overlay.id != id)
        .toList();
    state = state.copyWith(textOverlays: newOverlays);
  }

  void addStickerOverlay(StickerOverlay overlay) {
    final newOverlays = [...state.stickerOverlays, overlay];
    state = state.copyWith(stickerOverlays: newOverlays);
  }

  void updateStickerOverlay(String id, StickerOverlay updatedOverlay) {
    final newOverlays = state.stickerOverlays
        .map((overlay) => overlay.id == id ? updatedOverlay : overlay)
        .toList();
    state = state.copyWith(stickerOverlays: newOverlays);
  }

  void removeStickerOverlay(String id) {
    final newOverlays = state.stickerOverlays
        .where((overlay) => overlay.id != id)
        .toList();
    state = state.copyWith(stickerOverlays: newOverlays);
  }

  void setFilter(ImageFilter? filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setCropRect(Rect? rect) {
    state = state.copyWith(cropRect: rect);
  }

  void setProcessedImage(File? image) {
    state = state.copyWith(processedImage: image);
  }
}

// Instagram-style filters
const List<ImageFilter> instagramFilters = [
  ImageFilter(
    name: 'None',
    matrix: [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0],
  ),
  ImageFilter(
    name: 'Clarendon',
    matrix: [
      1.2,
      0,
      0,
      0,
      -10,
      0,
      1.1,
      0,
      0,
      -10,
      0,
      0,
      0.9,
      0,
      10,
      0,
      0,
      0,
      1,
      0,
    ],
  ),
  ImageFilter(
    name: 'Gingham',
    matrix: [
      1.1,
      0,
      0,
      0,
      20,
      0,
      1.0,
      0,
      0,
      10,
      0,
      0,
      0.9,
      0,
      -5,
      0,
      0,
      0,
      1,
      0,
    ],
  ),
  ImageFilter(
    name: 'Moon',
    matrix: [1.0, 0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 0, 1, 0],
  ),
  ImageFilter(
    name: 'Lark',
    matrix: [
      1.0,
      0,
      0,
      0,
      20,
      0,
      1.0,
      0,
      0,
      10,
      0,
      0,
      0.8,
      0,
      -10,
      0,
      0,
      0,
      1,
      0,
    ],
  ),
  ImageFilter(
    name: 'Reyes',
    matrix: [
      1.1,
      0,
      0,
      0,
      -10,
      0,
      1.0,
      0,
      0,
      -10,
      0,
      0,
      0.8,
      0,
      20,
      0,
      0,
      0,
      1,
      0,
    ],
  ),
  ImageFilter(
    name: 'Juno',
    matrix: [
      1.0,
      0,
      0,
      0,
      10,
      0,
      1.0,
      0,
      0,
      10,
      0,
      0,
      0.9,
      0,
      -5,
      0,
      0,
      0,
      1,
      0,
    ],
  ),
  ImageFilter(
    name: 'Slumber',
    matrix: [
      1.0,
      0,
      0,
      0,
      -5,
      0,
      1.0,
      0,
      0,
      -5,
      0,
      0,
      1.0,
      0,
      5,
      0,
      0,
      0,
      1,
      0,
    ],
  ),
  ImageFilter(
    name: 'Crema',
    matrix: [
      1.1,
      0,
      0,
      0,
      10,
      0,
      1.0,
      0,
      0,
      5,
      0,
      0,
      0.9,
      0,
      -5,
      0,
      0,
      0,
      1,
      0,
    ],
  ),
  ImageFilter(
    name: 'Ludwig',
    matrix: [
      1.0,
      0,
      0,
      0,
      20,
      0,
      1.0,
      0,
      0,
      10,
      0,
      0,
      0.8,
      0,
      -10,
      0,
      0,
      0,
      1,
      0,
    ],
  ),
  ImageFilter(
    name: 'Aden',
    matrix: [
      0.9,
      0,
      0,
      0,
      20,
      0,
      1.0,
      0,
      0,
      10,
      0,
      0,
      1.1,
      0,
      -10,
      0,
      0,
      0,
      1,
      0,
    ],
  ),
  ImageFilter(
    name: 'Perpetua',
    matrix: [
      1.0,
      0,
      0,
      0,
      10,
      0,
      0.9,
      0,
      0,
      5,
      0,
      0,
      1.1,
      0,
      -5,
      0,
      0,
      0,
      1,
      0,
    ],
  ),
];

class ImageEditorScreen extends ConsumerWidget {
  final File imageFile;

  const ImageEditorScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(imageEditorProvider);
    final editorNotifier = ref.read(imageEditorProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Photo', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: editorState.isLoading
                ? null
                : () => _nextStep(context, ref, editorState),
            child: Text(
              'Next',
              style: TextStyle(
                color: editorState.isLoading ? Colors.grey : Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Image Preview
          const Expanded(flex: 3, child: ImagePreviewSection()),

          // Editing Tools
          const EditingToolsSection(),

          // Caption Input
          CaptionInputSection(
            editorNotifier: editorNotifier,
            editorState: editorState,
          ),
        ],
      ),
    );
  }

  void _nextStep(
    BuildContext context,
    WidgetRef ref,
    ImageEditorState state,
  ) async {
    final notifier = ref.read(imageEditorProvider.notifier);
    notifier.setLoading(true);

    try {
      // Export the edited image
      final exportedImage = await _exportEditedImage(state);
      if (exportedImage != null) {
        // Navigate to post creation screen with edited image and caption
        context.push(
          '/create-post',
          extra: {
            'imageFile': exportedImage,
            'caption': state.caption,
            'hashtags': state.hashtags,
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      notifier.setLoading(false);
    }
  }

  Future<File?> _exportEditedImage(ImageEditorState state) async {
    try {
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Read original image
      final originalBytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(originalBytes);

      if (image == null) return null;

      // Apply adjustments
      if (state.brightness != 0.0 ||
          state.contrast != 1.0 ||
          state.saturation != 1.0) {
        image = img.adjustColor(
          image,
          brightness: state.brightness,
          contrast: state.contrast,
          saturation: state.saturation,
        );
      }

      // Apply rotation
      if (state.rotation != 0.0) {
        image = img.copyRotate(image, angle: state.rotation.toInt());
      }

      // Save the processed image
      final processedFile = File(outputPath);
      await processedFile.writeAsBytes(img.encodeJpg(image));

      // Compress the image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        processedFile.path,
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
        quality: 85,
      );

      return compressedFile != null ? File(compressedFile.path) : processedFile;
    } catch (e) {
      print('Error exporting image: $e');
      return null;
    }
  }
}

// Separate widgets for better organization

class ImagePreviewSection extends ConsumerStatefulWidget {
  const ImagePreviewSection({super.key});

  @override
  ConsumerState<ImagePreviewSection> createState() =>
      _ImagePreviewSectionState();
}

class _ImagePreviewSectionState extends ConsumerState<ImagePreviewSection> {
  String? _selectedOverlayId;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final editorState = ref.watch(imageEditorProvider);
        final imageFile =
            (context.findAncestorWidgetOfExactType<ImageEditorScreen>()
                    as ImageEditorScreen)
                .imageFile;

        return Container(
          color: Colors.black,
          child: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Stack(
                children: [
                  // Base image with filters and adjustments
                  ColorFiltered(
                    colorFilter: ColorFilter.matrix(
                      _buildColorMatrix(editorState),
                    ),
                    child: Transform.rotate(
                      angle: editorState.rotation * (math.pi / 180),
                      child: Image.file(imageFile, fit: BoxFit.contain),
                    ),
                  ),

                  // Text overlays
                  ...editorState.textOverlays.map(
                    (overlay) => _buildTextOverlay(overlay, ref),
                  ),

                  // Sticker overlays
                  ...editorState.stickerOverlays.map(
                    (overlay) => _buildStickerOverlay(overlay, ref),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<double> _buildColorMatrix(ImageEditorState state) {
    // Apply brightness, contrast, saturation adjustments
    final brightness = state.brightness;
    final contrast = state.contrast;
    final saturation = state.saturation;

    // Base identity matrix
    final List<double> matrix = <double>[
      1,
      0,
      0,
      0,
      brightness * 255,
      0,
      1,
      0,
      0,
      brightness * 255,
      0,
      0,
      1,
      0,
      brightness * 255,
      0,
      0,
      0,
      1,
      0,
    ];

    // Apply contrast
    final List<double> contrastMatrix = <double>[
      contrast,
      0,
      0,
      0,
      (1 - contrast) * 128,
      0,
      contrast,
      0,
      0,
      (1 - contrast) * 128,
      0,
      0,
      contrast,
      0,
      (1 - contrast) * 128,
      0,
      0,
      0,
      1,
      0,
    ];

    // Apply saturation (simplified)
    final List<double> saturationMatrix = <double>[
      0.3086 * (1 - saturation) + saturation,
      0.6094 * (1 - saturation),
      0.0820 * (1 - saturation),
      0,
      0,
      0.3086 * (1 - saturation),
      0.6094 * (1 - saturation) + saturation,
      0.0820 * (1 - saturation),
      0,
      0,
      0.3086 * (1 - saturation),
      0.6094 * (1 - saturation),
      0.0820 * (1 - saturation) + saturation,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];

    // Combine matrices
    final List<double> combinedMatrix = _multiplyMatrices(
      matrix,
      contrastMatrix,
    );
    final List<double> finalMatrix = _multiplyMatrices(
      combinedMatrix,
      saturationMatrix,
    );

    // Apply filter if selected
    if (state.selectedFilter != null) {
      return _multiplyMatrices(finalMatrix, state.selectedFilter!.matrix);
    }

    return finalMatrix;
  }

  List<double> _multiplyMatrices(List<double> a, List<double> b) {
    final result = List<double>.filled(20, 0.0);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 5; j++) {
        double sum = 0.0;
        for (int k = 0; k < 4; k++) {
          sum += a[i * 5 + k] * b[k * 5 + j];
        }
        result[i * 5 + j] = sum;
      }
    }
    return result;
  }

  Widget _buildTextOverlay(TextOverlay overlay, WidgetRef ref) {
    final isSelected = _selectedOverlayId == overlay.id;
    final notifier = ref.read(imageEditorProvider.notifier);

    return Positioned(
      left: overlay.position.dx,
      top: overlay.position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedOverlayId = overlay.id);
        },
        onPanStart: (_) {
          setState(() {
            _selectedOverlayId = overlay.id;
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          if (_isDragging && _selectedOverlayId == overlay.id) {
            final newPosition = overlay.position + details.delta;
            final updatedOverlay = overlay.copyWith(position: newPosition);
            notifier.updateTextOverlay(overlay.id, updatedOverlay);
          }
        },
        onPanEnd: (_) {
          setState(() => _isDragging = false);
        },
        child: Transform.scale(
          scale: overlay.scale,
          child: Transform.rotate(
            angle: overlay.rotation * (math.pi / 180),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: isSelected
                  ? BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text(
                overlay.text,
                style: TextStyle(
                  color: overlay.color,
                  fontSize: overlay.fontSize,
                  fontWeight: overlay.fontWeight,
                  fontFamily: overlay.fontFamily,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(1, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStickerOverlay(StickerOverlay overlay, WidgetRef ref) {
    final isSelected = _selectedOverlayId == overlay.id;
    final notifier = ref.read(imageEditorProvider.notifier);

    return Positioned(
      left: overlay.position.dx,
      top: overlay.position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedOverlayId = overlay.id);
        },
        onPanStart: (_) {
          setState(() {
            _selectedOverlayId = overlay.id;
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          if (_isDragging && _selectedOverlayId == overlay.id) {
            final newPosition = overlay.position + details.delta;
            final updatedOverlay = overlay.copyWith(position: newPosition);
            notifier.updateStickerOverlay(overlay.id, updatedOverlay);
          }
        },
        onPanEnd: (_) {
          setState(() => _isDragging = false);
        },
        child: Transform.scale(
          scale: overlay.scale,
          child: Transform.rotate(
            angle: overlay.rotation * (math.pi / 180),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: isSelected
                  ? BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text(overlay.emoji, style: const TextStyle(fontSize: 48)),
            ),
          ),
        ),
      ),
    );
  }
}

class EditingToolsSection extends ConsumerWidget {
  const EditingToolsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 120,
      color: Colors.grey[900],
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          ToolButton(
            icon: Icons.brightness_6,
            label: 'Brightness',
            onTap: () =>
                _showAdjustmentDialog(context, ref, AdjustmentType.brightness),
          ),
          ToolButton(
            icon: Icons.contrast,
            label: 'Contrast',
            onTap: () =>
                _showAdjustmentDialog(context, ref, AdjustmentType.contrast),
          ),
          ToolButton(
            icon: Icons.color_lens,
            label: 'Saturation',
            onTap: () =>
                _showAdjustmentDialog(context, ref, AdjustmentType.saturation),
          ),
          ToolButton(
            icon: Icons.rotate_right,
            label: 'Rotate',
            onTap: () =>
                _showAdjustmentDialog(context, ref, AdjustmentType.rotation),
          ),
          ToolButton(
            icon: Icons.filter,
            label: 'Filters',
            onTap: () => _showFiltersDialog(context),
          ),
          ToolButton(
            icon: Icons.crop,
            label: 'Crop',
            onTap: () => _showCropDialog(context),
          ),
          ToolButton(
            icon: Icons.text_fields,
            label: 'Text',
            onTap: () => _showTextDialog(context),
          ),
          ToolButton(
            icon: Icons.emoji_emotions,
            label: 'Stickers',
            onTap: () => _showStickersDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAdjustmentDialog(
    BuildContext context,
    WidgetRef ref,
    AdjustmentType type,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => AdjustmentSliderDialog(type: type),
    );
  }

  void _showFiltersDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (context) => const FiltersDialog(),
    );
  }

  void _showCropDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => const CropOptionsDialog(),
    );
  }

  void _showTextDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddTextDialog());
  }

  void _showStickersDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => const StickersDialog(),
    );
  }
}

class CaptionInputSection extends StatelessWidget {
  final ImageEditorNotifier editorNotifier;
  final ImageEditorState editorState;

  const CaptionInputSection({
    super.key,
    required this.editorNotifier,
    required this.editorState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add a caption...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 3,
            maxLength: 2200,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Write a caption...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              filled: true,
              fillColor: Colors.grey[800],
            ),
            onChanged: editorNotifier.updateCaption,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: editorState.hashtags
                .map(
                  (tag) => Chip(
                    label: Text(
                      '#$tag',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => editorNotifier.removeHashtag(tag),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// Reusable components

class ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ToolButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

enum AdjustmentType { brightness, contrast, saturation, rotation }

class AdjustmentSliderDialog extends ConsumerWidget {
  final AdjustmentType type;

  const AdjustmentSliderDialog({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageEditorProvider);
    final notifier = ref.read(imageEditorProvider.notifier);

    late String title;
    late double value;
    late double min;
    late double max;
    late VoidCallback reset;

    switch (type) {
      case AdjustmentType.brightness:
        title = 'Brightness';
        value = state.brightness;
        min = -1.0;
        max = 1.0;
        reset = () => notifier.updateBrightness(0.0);
        break;
      case AdjustmentType.contrast:
        title = 'Contrast';
        value = state.contrast;
        min = 0.0;
        max = 2.0;
        reset = () => notifier.updateContrast(1.0);
        break;
      case AdjustmentType.saturation:
        title = 'Saturation';
        value = state.saturation;
        min = 0.0;
        max = 2.0;
        reset = () => notifier.updateSaturation(1.0);
        break;
      case AdjustmentType.rotation:
        title = 'Rotation';
        value = state.rotation;
        min = -180.0;
        max = 180.0;
        reset = () => notifier.updateRotation(0.0);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            onChanged: (newValue) {
              switch (type) {
                case AdjustmentType.brightness:
                  notifier.updateBrightness(newValue);
                  break;
                case AdjustmentType.contrast:
                  notifier.updateContrast(newValue);
                  break;
                case AdjustmentType.saturation:
                  notifier.updateSaturation(newValue);
                  break;
                case AdjustmentType.rotation:
                  notifier.updateRotation(newValue);
                  break;
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: reset, child: const Text('Reset')),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FiltersDialog extends ConsumerWidget {
  const FiltersDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(imageEditorProvider.notifier);
    final selectedFilter = ref.watch(imageEditorProvider).selectedFilter;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: instagramFilters.length,
              itemBuilder: (context, index) {
                final filter = instagramFilters[index];
                final isSelected = selectedFilter?.name == filter.name;

                return GestureDetector(
                  onTap: () {
                    notifier.setFilter(isSelected ? null : filter);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors
                                .primaries[index % Colors.primaries.length],
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          filter.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CropOptionsDialog extends ConsumerWidget {
  const CropOptionsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageFile =
        (context.findAncestorWidgetOfExactType<ImageEditorScreen>()
                as ImageEditorScreen)
            .imageFile;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Crop Options',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCropOption(
                context,
                '1:1',
                CropAspectRatio(ratioX: 1, ratioY: 1),
              ),
              _buildCropOption(
                context,
                '4:5',
                CropAspectRatio(ratioX: 4, ratioY: 5),
              ),
              _buildCropOption(
                context,
                '16:9',
                CropAspectRatio(ratioX: 16, ratioY: 9),
              ),
              _buildCropOption(context, 'Free', null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCropOption(
    BuildContext context,
    String label,
    CropAspectRatio? aspectRatio,
  ) {
    return GestureDetector(
      onTap: () async {
        final imageFile =
            (context.findAncestorWidgetOfExactType<ImageEditorScreen>()
                    as ImageEditorScreen)
                .imageFile;

        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: imageFile.path,
          aspectRatio: aspectRatio,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: aspectRatio != null,
            ),
            IOSUiSettings(title: 'Crop Image'),
          ],
        );

        if (croppedFile != null) {
          // For now, just close the dialog. In a full implementation,
          // you'd update the image file state
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              aspectRatio != null ? Icons.crop : Icons.crop_free,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AddTextDialog extends ConsumerStatefulWidget {
  const AddTextDialog({super.key});

  @override
  ConsumerState<AddTextDialog> createState() => _AddTextDialogState();
}

class _AddTextDialogState extends ConsumerState<AddTextDialog> {
  final TextEditingController _textController = TextEditingController();
  Color _selectedColor = Colors.white;
  double _fontSize = 24.0;

  final List<Color> _colors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.pink,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Add Text', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter text...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Font Size', style: TextStyle(color: Colors.white)),
                Slider(
                  value: _fontSize,
                  min: 12,
                  max: 48,
                  onChanged: (value) => setState(() => _fontSize = value),
                ),
                const SizedBox(height: 16),
                const Text('Color', style: TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _colors
                      .map(
                        (color) => GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color: _selectedColor == color
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  final notifier = ref.read(imageEditorProvider.notifier);
                  final overlay = TextOverlay(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    text: _textController.text,
                    position: const Offset(50, 50), // Default position
                    color: _selectedColor,
                    fontSize: _fontSize,
                  );
                  notifier.addTextOverlay(overlay);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class StickersDialog extends ConsumerWidget {
  const StickersDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(imageEditorProvider.notifier);

    final List<String> emojis = [
      '😀',
      '😂',
      '🥰',
      '😍',
      '🤗',
      '😉',
      '😎',
      '🤔',
      '😴',
      '😭',
      '😡',
      '🥺',
      '😇',
      '🤪',
      '🤓',
      '😈',
      '👻',
      '🎃',
      '🎉',
      '🎊',
      '💖',
      '💕',
      '💯',
      '🔥',
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Stickers',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                final emoji = emojis[index];
                return GestureDetector(
                  onTap: () {
                    final overlay = StickerOverlay(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      emoji: emoji,
                      position: Offset(
                        50 + (index * 10),
                        100 + (index * 10),
                      ), // Varied positions
                    );
                    notifier.addStickerOverlay(overlay);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
