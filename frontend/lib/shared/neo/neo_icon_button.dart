import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';

/// Tactile Neo-Brutalist Icon Button.
/// Provides an accessible touch target (>= 48px), thick black border, and hard shadow.
class NeoIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double iconSize;
  final BorderRadiusGeometry borderRadius;
  final Offset shadowOffset;

  const NeoIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.backgroundColor = NeoTokens.white,
    this.iconColor = NeoTokens.black,
    this.size = 48.0,
    this.iconSize = 22.0,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(NeoTokens.radiusMedium),
    ),
    this.shadowOffset = NeoTokens.shadowOffsetSmall,
  });

  @override
  State<NeoIconButton> createState() => _NeoIconButtonState();
}

class _NeoIconButtonState extends State<NeoIconButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null;

  void _onTapDown(TapDownDetails _) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (_isEnabled) {
      setState(() => _isPressed = false);
    }
  }

  void _onTapCancel() {
    if (_isEnabled) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentOffset = _isEnabled && !_isPressed
        ? widget.shadowOffset
        : Offset.zero;
    final translateOffset = _isEnabled && _isPressed
        ? widget.shadowOffset
        : Offset.zero;

    Widget btn = GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _isEnabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(
          translateOffset.dx,
          translateOffset.dy,
          0,
        ),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isEnabled ? widget.backgroundColor : NeoTokens.surfaceMuted,
          borderRadius: widget.borderRadius,
          border: Border.all(
            color: NeoTokens.black,
            width: NeoTokens.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: NeoTokens.black,
              offset: currentOffset,
              blurRadius: NeoTokens.shadowBlurRadius,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          widget.icon,
          size: widget.iconSize,
          color: _isEnabled ? widget.iconColor : NeoTokens.textLight,
        ),
      ),
    );

    if (widget.tooltip != null) {
      btn = Tooltip(message: widget.tooltip!, child: btn);
    }

    return btn;
  }
}
