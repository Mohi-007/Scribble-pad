import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

enum DrawingTool {
  pen,
  eraser,
  line,
  rectangle,
  circle,
  triangle,
  arrow,
  star,
  text,
  image,
}

enum CanvasGridType {
  none,
  dots,
  grid,
}

class ImageElement {
  final Offset position;
  final ui.Image image;
  final double scale;
  final double rotation;

  ImageElement({
    required this.position,
    required this.image,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}

class TextElement {
  final Offset position;
  final String text;
  final Color color;
  final double fontSize;

  TextElement({
    required this.position,
    required this.text,
    required this.color,
    required this.fontSize,
  });
}

class DrawingPath {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final DrawingTool toolType;

  DrawingPath({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.toolType,
  });

  DrawingPath copyWith({
    List<Offset>? points,
    Color? color,
    double? strokeWidth,
    DrawingTool? toolType,
  }) {
    return DrawingPath(
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      toolType: toolType ?? this.toolType,
    );
  }
}

class DrawingProvider extends ChangeNotifier {
  final List<DrawingPath> _paths = [];
  final List<DrawingPath> _redoStack = [];
  final List<TextElement> _textElements = [];
  final List<ImageElement> _imageElements = [];

  Color _currentColor = const Color(0xFF6C5CE7); // Modern Electric Violet
  double _currentStrokeWidth = 5.0;
  DrawingTool _currentTool = DrawingTool.pen;
  ui.Image? _backgroundImage;
  String? _activeAiPresetName;
  CanvasGridType _gridType = CanvasGridType.dots;
  bool _isGeneratingAi = false;
  String _aiStatusMessage = '';

  List<DrawingPath> get paths => List.unmodifiable(_paths);
  List<TextElement> get textElements => List.unmodifiable(_textElements);
  List<ImageElement> get imageElements => List.unmodifiable(_imageElements);
  Color get currentColor => _currentColor;
  double get currentStrokeWidth => _currentStrokeWidth;
  DrawingTool get currentTool => _currentTool;
  bool get isEraserMode => _currentTool == DrawingTool.eraser;
  ui.Image? get backgroundImage => _backgroundImage;
  String? get activeAiPresetName => _activeAiPresetName;
  CanvasGridType get gridType => _gridType;
  bool get isGeneratingAi => _isGeneratingAi;
  String get aiStatusMessage => _aiStatusMessage;

  bool get canUndo => _paths.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void setGridType(CanvasGridType type) {
    _gridType = type;
    notifyListeners();
  }

  void toggleGrid() {
    if (_gridType == CanvasGridType.none) {
      _gridType = CanvasGridType.dots;
    } else if (_gridType == CanvasGridType.dots) {
      _gridType = CanvasGridType.grid;
    } else {
      _gridType = CanvasGridType.none;
    }
    notifyListeners();
  }

  /// Load a realistic AI preset canvas background from assets
  Future<void> loadAssetBackground(String assetPath, String presetName) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      _backgroundImage = await _loadImage(bytes);
      _activeAiPresetName = presetName;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading asset background: $e');
    }
  }

  /// Simulate realistic AI Art Generation with dynamic updates
  Future<void> generateAiArtCanvas(String prompt, String assetFallback) async {
    _isGeneratingAi = true;
    _aiStatusMessage = 'Connecting to Neural Model...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    _aiStatusMessage = 'Synthesizing photorealistic texture layers...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));
    _aiStatusMessage = 'Applying prompt details: "$prompt"...';
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));
    await loadAssetBackground(assetFallback, prompt);

    _isGeneratingAi = false;
    _aiStatusMessage = '';
    notifyListeners();
  }

  /// Pick an image and set it as background — works on both Web and mobile.
  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        _backgroundImage = await _loadImage(bytes);
        _activeAiPresetName = 'Custom Image';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void setBackgroundImage(ui.Image? image, [String? presetName]) {
    _backgroundImage = image;
    _activeAiPresetName = presetName;
    notifyListeners();
  }

  void setColor(Color color) {
    _currentColor = color;
    if (_currentTool == DrawingTool.eraser) {
      _currentTool = DrawingTool.pen;
    }
    notifyListeners();
  }

  void setStrokeWidth(double width) {
    _currentStrokeWidth = width;
    notifyListeners();
  }

  void setTool(DrawingTool tool) {
    _currentTool = tool;
    notifyListeners();
  }

  void addPath(DrawingPath path) {
    _paths.add(path);
    _redoStack.clear();
    notifyListeners();
  }

  void updateLastPath(Offset point) {
    if (_paths.isNotEmpty) {
      final lastPath = _paths.last;

      if (lastPath.toolType == DrawingTool.pen ||
          lastPath.toolType == DrawingTool.eraser) {
        final updatedPoints = List<Offset>.from(lastPath.points)..add(point);
        _paths[_paths.length - 1] = lastPath.copyWith(points: updatedPoints);
      } else {
        final updatedPoints = [lastPath.points[0], point];
        _paths[_paths.length - 1] = lastPath.copyWith(points: updatedPoints);
      }
      notifyListeners();
    }
  }

  void undo() {
    if (_paths.isNotEmpty) {
      _redoStack.add(_paths.removeLast());
      notifyListeners();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      _paths.add(_redoStack.removeLast());
      notifyListeners();
    }
  }

  void addText(String text, Offset position) {
    _textElements.add(
      TextElement(
        position: position,
        text: text,
        color: _currentColor,
        fontSize: _currentStrokeWidth * 4,
      ),
    );
    _redoStack.clear();
    notifyListeners();
  }

  void addImageElement(ui.Image image, Offset position) {
    _imageElements.add(ImageElement(position: position, image: image));
    notifyListeners();
  }

  /// Import an image as a draggable element — works on both Web and mobile.
  Future<void> importImage([Offset? position]) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final image = await _loadImage(bytes);
        addImageElement(image, position ?? const Offset(100, 100));
      }
    } catch (e) {
      debugPrint('Error importing image: $e');
    }
  }

  /// Import a file (images) via file_picker — works on both Web and mobile.
  Future<void> importFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        _backgroundImage = await _loadImage(bytes);
        _activeAiPresetName = 'Uploaded File';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error importing file: $e');
    }
  }

  /// Save the drawing as a PNG file using file_picker's saveFile dialog.
  Future<String> saveImageToFile(Uint8List pngBytes) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save your Scribble Pad drawing',
        fileName: 'scribble_ai_${DateTime.now().millisecondsSinceEpoch}.png',
        type: FileType.image,
        bytes: pngBytes,
      );

      if (result != null) {
        return 'Drawing saved successfully!';
      } else {
        return 'Save cancelled.';
      }
    } catch (e) {
      debugPrint('Error saving file: $e');
      return 'Error saving: $e';
    }
  }

  Future<ui.Image> _loadImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  void clear() {
    _paths.clear();
    _redoStack.clear();
    _textElements.clear();
    _imageElements.clear();
    _backgroundImage = null;
    _activeAiPresetName = null;
    notifyListeners();
  }
}
