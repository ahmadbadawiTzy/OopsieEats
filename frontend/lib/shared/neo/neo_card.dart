import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';

/// Neo-Brutalist Card widget.
/// Features:
/// - Crisp, thick near-black border
/// - Hard offset shadow (no blur)
/// - Flat surface background
/// - Optional interactive press-down animation when `onTap` is provided
class NeoCard extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final double borderWidth;
  final Offset shadowOffset;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const NeoCard({
    super.key,
    required this.child,
    this.backgroundColor = NeoTokens.white,
    this.borderColor = NeoTokens.black,
    this.shadowColor = NeoTokens.black,
    this.borderWidth = NeoTokens.borderWidth,
    this.shadowOffset = NeoTokens.shadowOffset,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(NeoTokens.radiusMedium),
    ),
    this.padding,
    this.margin,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  State<NeoCard> createState() => _NeoCardState();
}

class _NeoCardState extends State<NeoCard> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentOffset = _isPressed ? Offset.zero : widget.shadowOffset;
    final translateOffset = _isPressed ? widget.shadowOffset : Offset.zero;

    Widget cardContent = Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding ?? const EdgeInsets.all(NeoTokens.space16),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: widget.borderRadius,
        border: Border.all(
          color: widget.borderColor,
          width: widget.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.shadowColor,
            offset: currentOffset,
            blurRadius: NeoTokens.shadowBlurRadius,
          ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      cardContent = GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(
            translateOffset.dx,
            translateOffset.dy,
            0,
          ),
          child: cardContent,
        ),
      );
    }

    if (widget.margin != null) {
      cardContent = Padding(padding: widget.margin!, child: cardContent);
    }

    return cardContent;
  }
}
