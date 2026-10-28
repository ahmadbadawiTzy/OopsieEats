import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';

/// Neo-Brutalist Text Input Field.
/// Encapsulates TextFormField in a bold black-bordered container with hard offset shadow.
class NeoInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;

  const NeoInput({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.onFieldSubmitted,
  });

  @override
  State<NeoInput> createState() => _NeoInputState();
}

class _NeoInputState extends State<NeoInput> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: NeoTokens.textDark,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: NeoTokens.space8),
        ],
        Container(
          decoration: BoxDecoration(
            color: widget.enabled ? NeoTokens.white : NeoTokens.surfaceMuted,
            borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
            border: Border.all(
              color: NeoTokens.black,
              width: _isFocused
                  ? NeoTokens.borderWidthThick
                  : NeoTokens.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: NeoTokens.black,
                offset: _isFocused
                    ? NeoTokens.shadowOffset
                    : NeoTokens.shadowOffsetSmall,
                blurRadius: NeoTokens.shadowBlurRadius,
              ),
            ],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: NeoTokens.textDark,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: NeoTokens.space16,
                vertical: NeoTokens.space16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
