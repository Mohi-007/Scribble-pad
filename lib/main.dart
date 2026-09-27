import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;

import 'drawing_provider.dart';
import 'drawing_canvas.dart';
import 'glass_container.dart';
import 'ai_studio_modal.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DrawingProvider(),
      child: const ScribblePadApp(),
    ),
  );
}

class ScribblePadApp extends StatelessWidget {
  const ScribblePadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scribble Pad AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF10111A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
          primary: const Color(0xFF6C5CE7),
          secondary: const Color(0xFFA29BFE),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const ScribblePadScreen(),
    );
  }
}

class ScribblePadScreen extends StatefulWidget {
  const ScribblePadScreen({super.key});

  @override
  State<ScribblePadScreen> createState() => _ScribblePadScreenState();
}

class _ScribblePadScreenState extends State<ScribblePadScreen> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _saveImage() async {
    final provider = Provider.of<DrawingProvider>(context, listen: false);
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final result = await provider.saveImageToFile(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFF6C5CE7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving image: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DrawingProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Drawing Canvas Area
          RepaintBoundary(
            key: _globalKey,
            child: const DrawingCanvas(),
          ),

          // 2. Active Canvas Stats & AI Preset HUD Tag
          Positioned(
            top: 110,
            left: 20,
            child: Row(
              children: [
                if (provider.activeAiPresetName != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'AI Canvas: ${provider.activeAiPresetName}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    'Strokes: ${provider.paths.length} | Text: ${provider.textElements.length} | Images: ${provider.imageElements.length}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Top Glass Header Toolbar
          const Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: TopToolbar(),
          ),

          // 4. Bottom Glass Dock Toolbar
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: BottomToolbar(onSave: _saveImage),
          ),
        ],
      ),
    );
  }
}

class TopToolbar extends StatelessWidget {
  const TopToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DrawingProvider>(context);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      borderRadius: 28,
      opacity: 0.35,
      blur: 20,
      borderColor: Colors.white.withValues(alpha: 0.15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // App Brand Logo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.gesture,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'Scribble Pad AI',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // AI Canvas Studio Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7).withValues(alpha: 0.8),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: Text(
                'AI Canvas',
                style: GoogleFonts.outfit(
                    fontSize: 13, fontWeight: FontWeight.bold),
              ),
              onPressed: () => AiStudioModal.show(context),
            ),
            const SizedBox(width: 12),

            // Grid Toggle Button
            IconButton(
              icon: Icon(
                provider.gridType == CanvasGridType.dots
                    ? Icons.grid_3x3
                    : provider.gridType == CanvasGridType.grid
                        ? Icons.grid_4x4
                        : Icons.grid_off,
                color: provider.gridType != CanvasGridType.none
                    ? const Color(0xFFA29BFE)
                    : Colors.white60,
              ),
              tooltip: 'Toggle Canvas Grid',
              onPressed: () => provider.toggleGrid(),
            ),

            // Undo / Redo
            IconButton(
              icon: const Icon(Icons.undo, color: Colors.white),
              tooltip: 'Undo',
              onPressed: provider.canUndo ? provider.undo : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo, color: Colors.white),
              tooltip: 'Redo',
              onPressed: provider.canRedo ? provider.redo : null,
            ),

            // Import File Button
            IconButton(
              icon: const Icon(Icons.upload_file, color: Colors.white),
              tooltip: 'Import Image File',
              onPressed: () => provider.importFile(),
            ),

            // Clear All Button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Clear Canvas',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1F2E),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Text(
                      'Clear Canvas',
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Are you sure you want to clear all drawings and AI backdrops?',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          provider.clear();
                          Navigator.pop(context);
                        },
                        child: const Text('Clear Canvas',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class BottomToolbar extends StatelessWidget {
  final VoidCallback onSave;
  const BottomToolbar({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DrawingProvider>(context);

    // Quick palette colors
    final List<Color> quickColors = [
      const Color(0xFF6C5CE7), // Electric Violet
      const Color(0xFFFF7675), // Soft Red
      const Color(0xFF00CEC9), // Cyan Glow
      const Color(0xFFFDCB6E), // Warm Amber
      const Color(0xFF00B894), // Emerald
      Colors.white,
      Colors.black,
    ];

    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        borderRadius: 36,
        opacity: 0.45,
        blur: 24,
        borderColor: Colors.white.withValues(alpha: 0.18),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Drawing Tools Group
              _ToolButton(
                icon: Icons.edit_rounded,
                label: 'Pen',
                isSelected: provider.currentTool == DrawingTool.pen,
                onPressed: () => provider.setTool(DrawingTool.pen),
              ),
              _ToolButton(
                icon: Icons.auto_fix_normal_rounded,
                label: 'Eraser',
                isSelected: provider.currentTool == DrawingTool.eraser,
                onPressed: () => provider.setTool(DrawingTool.eraser),
              ),
              const VerticalDivider(
                  width: 16, color: Colors.white24, indent: 8, endIndent: 8),

              // 2. Shape Selector Dropdown
              _ShapePopupMenu(
                currentTool: provider.currentTool,
                onSelected: (tool) => provider.setTool(tool),
              ),

              // 3. Canvas Insertion Tools (Image & Text)
              _ToolButton(
                icon: Icons.add_photo_alternate_rounded,
                label: 'Image',
                isSelected: provider.currentTool == DrawingTool.image,
                onPressed: () => provider.setTool(DrawingTool.image),
              ),
              _ToolButton(
                icon: Icons.text_fields_rounded,
                label: 'Text',
                isSelected: provider.currentTool == DrawingTool.text,
                onPressed: () => provider.setTool(DrawingTool.text),
              ),
              const VerticalDivider(
                  width: 16, color: Colors.white24, indent: 8, endIndent: 8),

              // 4. Quick Color Swatches + Color Picker
              Row(
                children: [
                  ...quickColors.map((color) {
                    final isSelected = provider.currentColor == color;
                    return GestureDetector(
                      onTap: () => provider.setColor(color),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.2),
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1F2E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          title: Text(
                            'Pick Brush Color',
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: provider.currentColor,
                              onColorChanged: provider.setColor,
                              colorPickerWidth: 260,
                              pickerAreaHeightPercent: 0.7,
                              enableAlpha: true,
                              displayThumbColor: true,
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C5CE7),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Apply',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white38),
                      ),
                      child: const Icon(Icons.palette_outlined,
                          size: 20, color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const VerticalDivider(
                  width: 16, color: Colors.white24, indent: 8, endIndent: 8),

              // 5. Stroke Size Slider & Live Brush Preview Circle
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: Container(
                      width: provider.currentStrokeWidth.clamp(4, 20).toDouble(),
                      height:
                          provider.currentStrokeWidth.clamp(4, 20).toDouble(),
                      decoration: BoxDecoration(
                        color: provider.isEraserMode
                            ? Colors.white54
                            : provider.currentColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        activeTrackColor: const Color(0xFF6C5CE7),
                        inactiveTrackColor: Colors.white24,
                        thumbColor: const Color(0xFFA29BFE),
                        overlayColor:
                            const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: provider.currentStrokeWidth,
                        min: 1,
                        max: 50,
                        onChanged: provider.setStrokeWidth,
                      ),
                    ),
                  ),
                ],
              ),
              const VerticalDivider(
                  width: 16, color: Colors.white24, indent: 8, endIndent: 8),

              // 6. Save Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0x806C5CE7),
                ),
                icon: const Icon(Icons.save_alt_rounded, size: 18),
                label: Text(
                  'Save',
                  style: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
                onPressed: onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShapePopupMenu extends StatelessWidget {
  final DrawingTool currentTool;
  final Function(DrawingTool) onSelected;

  const _ShapePopupMenu(
      {required this.currentTool, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final List<DrawingTool> shapeTools = [
      DrawingTool.line,
      DrawingTool.rectangle,
      DrawingTool.circle,
      DrawingTool.triangle,
      DrawingTool.arrow,
      DrawingTool.star,
    ];

    bool isShapeSelected = shapeTools.contains(currentTool);

    return PopupMenuButton<DrawingTool>(
      initialValue: currentTool,
      onSelected: onSelected,
      tooltip: 'Shapes',
      color: const Color(0xFF1E1F2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => [
        _buildMenuItem(DrawingTool.line, Icons.linear_scale, 'Line'),
        _buildMenuItem(DrawingTool.rectangle, Icons.crop_square, 'Rectangle'),
        _buildMenuItem(DrawingTool.circle, Icons.circle_outlined, 'Circle'),
        _buildMenuItem(DrawingTool.triangle, Icons.change_history, 'Triangle'),
        _buildMenuItem(DrawingTool.arrow, Icons.arrow_right_alt, 'Arrow'),
        _buildMenuItem(DrawingTool.star, Icons.star_outline, 'Star'),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isShapeSelected
              ? const Color(0xFF6C5CE7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isShapeSelected
                  ? _getIconForTool(currentTool)
                  : Icons.interests_outlined,
              size: 18,
              color: isShapeSelected ? Colors.white : Colors.white70,
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white60, size: 18),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<DrawingTool> _buildMenuItem(
      DrawingTool tool, IconData icon, String label) {
    return PopupMenuItem(
      value: tool,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFA29BFE)),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.inter(color: Colors.white)),
        ],
      ),
    );
  }

  IconData _getIconForTool(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.line:
        return Icons.linear_scale;
      case DrawingTool.rectangle:
        return Icons.crop_square;
      case DrawingTool.circle:
        return Icons.circle_outlined;
      case DrawingTool.triangle:
        return Icons.change_history;
      case DrawingTool.arrow:
        return Icons.arrow_right_alt;
      case DrawingTool.star:
        return Icons.star_outline;
      default:
        return Icons.interests_outlined;
    }
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C5CE7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
