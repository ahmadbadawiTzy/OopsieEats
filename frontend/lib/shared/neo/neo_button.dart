import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/app_icons.dart';

enum NeoButtonVariant {
  primary, // Acid Lime (Hero Action)
  cobalt, // Electric Cobalt Blue (Submit / Profile)
  hazard, // Hazard Yellow (Caution / Highlights)
  accent, // Acid Lime
  secondary, // Crisp White Paper
  danger, // Alert Red
  dark, // Near-Black Ink
}

/// Tactile Neo-Brutalist Button.
/// Pressing down moves the button into its hard offset shadow for a tactile physical click.
class NeoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final NeoButtonVariant variant;
  final Color? customBackgroundColor;
  final Color? customTextColor;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final IconData? suffixIcon;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final BorderRadiusGeometry borderRadius;
  final Offset shadowOffset;
  final double borderWidth;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;

  const NeoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = NeoButtonVariant.primary,
    this.customBackgroundColor,
    this.customTextColor,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 52.0,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(NeoTokens.radiusMedium),
    ),
    this.shadowOffset = NeoTokens.shadowOffset,
    this.borderWidth = NeoTokens.borderWidth,
    this.textStyle,
    this.padding,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _isPressed = false;

  Color get _backgroundColor {
    if (widget.customBackgroundColor != null) {
      return widget.customBackgroundColor!;
    }
    switch (widget.variant) {
      case NeoButtonVariant.primary:
      case NeoButtonVariant.accent:
        return NeoTokens.lime;
      case NeoButtonVariant.cobalt:
        return NeoTokens.cobalt;
      case NeoButtonVariant.hazard:
        return NeoTokens.hazard;
      case NeoButtonVariant.secondary:
        return NeoTokens.paper;
      case NeoButtonVariant.danger:
        return NeoTokens.alert;
      case NeoButtonVariant.dark:
        return NeoTokens.ink;
    }
  }

  Color get _textColor {
    if (widget.customTextColor != null) {
      return widget.customTextColor!;
    }
    switch (widget.variant) {
      case NeoButtonVariant.dark:
      case NeoButtonVariant.danger:
      case NeoButtonVariant.cobalt:
        return NeoTokens.paper;
      default:
        return NeoTokens.ink;
    }
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

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
    final effectiveBg = _isEnabled ? _backgroundColor : NeoTokens.surfaceMuted;
    final effectiveFg = _isEnabled ? _textColor : NeoTokens.textLight;
    final effectiveShadow = _isEnabled && !_isPressed
        ? widget.shadowOffset
        : Offset.zero;
    final translateOffset = _isEnabled && _isPressed
        ? widget.shadowOffset
        : Offset.zero;

    Widget buttonChild = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.6,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
            ),
          )
        else ...[
          if (widget.prefixWidget != null) ...[
            widget.prefixWidget!,
            const SizedBox(width: NeoTokens.space8),
          ] else if (widget.prefixIcon != null) ...[
            Icon(
              widget.prefixIcon,
              size: AppIcons.sizeControl,
              color: effectiveFg,
            ),
            const SizedBox(width: NeoTokens.space8),
          ],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.text,
                maxLines: 1,
                style:
                    widget.textStyle ??
                    TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: effectiveFg,
                      letterSpacing: -0.2,
                    ),
              ),
            ),
          ),
          if (widget.suffixIcon != null) ...[
            const SizedBox(width: NeoTokens.space8),
            Icon(
              widget.suffixIcon,
              size: AppIcons.sizeControl,
              color: effectiveFg,
            ),
          ],
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.text,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: NeoMotion.getDuration(context, NeoMotion.durationFast),
          curve: NeoMotion.curveStandard,
          transform: Matrix4.translationValues(
            translateOffset.dx,
            translateOffset.dy,
            0,
          ),
          height: widget.height,
          width: widget.isFullWidth ? double.infinity : null,
          padding:
              widget.padding ??
              const EdgeInsets.symmetric(horizontal: NeoTokens.space20),
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: widget.borderRadius,
            border: Border.all(
              color: NeoTokens.black,
              width: widget.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: NeoTokens.black,
                offset: effectiveShadow,
                blurRadius: NeoTokens.shadowBlurRadius,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: buttonChild,
        ),
      ),
    );
  }
}
