import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16,
    this.opacity = 0.25,
    this.borderRadius = 24,
    this.padding,
    this.margin,
    this.borderColor,
    this.backgroundColor,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (backgroundColor ?? const Color(0xFF1E1F2E))
                  .withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? Colors.white.withValues(alpha: 0.15),
                width: 1.2,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
