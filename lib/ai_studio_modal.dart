import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'drawing_provider.dart';

class AiStudioModal extends StatefulWidget {
  const AiStudioModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const AiStudioModal(),
    );
  }

  @override
  State<AiStudioModal> createState() => _AiStudioModalState();
}

class _AiStudioModalState extends State<AiStudioModal> {
  final TextEditingController _promptController = TextEditingController(
    text: 'Photorealistic oil painting canvas with rich abstract brush strokes',
  );

  final List<Map<String, String>> _presetStyles = [
    {
      'title': 'Oil Painting',
      'icon': '🎨',
      'asset': 'assets/images/ai_bg1.png',
      'prompt':
          'Photorealistic oil painting canvas with rich abstract brush strokes'
    },
    {
      'title': 'Cyberpunk Neon',
      'icon': '⚡',
      'asset': 'assets/images/ai_bg2.png',
      'prompt': 'Realistic cyberpunk glowing neon grid digital art backdrop'
    },
    {
      'title': 'Watercolor Paper',
      'icon': '📜',
      'asset': 'assets/images/ai_bg3.png',
      'prompt':
          'Photorealistic fine watercolor paper texture with soft ink wash'
    },
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DrawingProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF141523),
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Color(0x666C5CE7),
              blurRadius: 30,
              spreadRadius: 2,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Canvas Studio',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Generate hyper-realistic AI canvas backdrops',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Preset Realistic Styles',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presetStyles.map((style) {
                  final isSelected =
                      provider.activeAiPresetName == style['title'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _promptController.text = style['prompt']!;
                        });
                        provider.loadAssetBackground(
                            style['asset']!, style['title']!);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6C5CE7)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFA29BFE)
                                : Colors.white.withValues(alpha: 0.1),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF6C5CE7)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(style['icon']!,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              style['title']!,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Custom AI Canvas Prompt',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _promptController,
              maxLines: 2,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Describe the AI canvas backdrop...',
                hintStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF6C5CE7),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (provider.isGeneratingAi)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Color(0xFFA29BFE),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        provider.aiStatusMessage,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFA29BFE),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    final prompt = _promptController.text.trim();
                    if (prompt.isNotEmpty) {
                      String fallbackAsset = 'assets/images/ai_bg1.png';
                      if (prompt.toLowerCase().contains('cyber') ||
                          prompt.toLowerCase().contains('neon')) {
                        fallbackAsset = 'assets/images/ai_bg2.png';
                      } else if (prompt.toLowerCase().contains('water') ||
                          prompt.toLowerCase().contains('paper')) {
                        fallbackAsset = 'assets/images/ai_bg3.png';
                      }

                      provider
                          .generateAiArtCanvas(prompt, fallbackAsset)
                          .then((_) {
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      });
                    }
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x806C5CE7),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Generate AI Canvas Background',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
