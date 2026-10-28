import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/app_icons.dart';

enum NeoNavTab { home, article, history, profile }

/// Premium Overkill Neo-Brutalist Floating Bottom Navigation Dock for NutriView.
/// - Truly floating, lifted from screen edges with balanced margins and safe area handling.
/// - Crisp structural border (2.0px), clean hard offset shadow (Offset(3, 4)), and refined corner radius.
/// - Five balanced, comfortable touch targets: BERANDA, ARTIKEL, PINDAI, RIWAYAT, PROFIL.
/// - Elevated centerpiece scan button integrated into the design hierarchy.
/// - Strictly ZERO emojis.
class NeoBottomNav extends StatelessWidget {
  final NeoNavTab activeTab;
  final ValueChanged<NeoNavTab> onTabSelected;
  final VoidCallback onScanPressed;

  const NeoBottomNav({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset > 0 ? 8 : 14),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: NeoTokens.paper,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: NeoTokens.ink,
              width: NeoTokens.borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: NeoTokens.ink,
                offset: Offset(3, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. BERANDA (Home)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: _NeoNavTabItem(
                    label: 'BERANDA',
                    icon: AppIcons.gridView,
                    isActive: activeTab == NeoNavTab.home,
                    onTap: () => onTabSelected(NeoNavTab.home),
                  ),
                ),
              ),

              // 2. ARTIKEL (Article)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: _NeoNavTabItem(
                    label: 'ARTIKEL',
                    icon: AppIcons.article,
                    isActive: activeTab == NeoNavTab.article,
                    onTap: () => onTabSelected(NeoNavTab.article),
                  ),
                ),
              ),

              // 3. PINDAI (Center Hero Scan Button)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: _NeoNavScanButton(onPressed: onScanPressed),
                ),
              ),

              // 4. RIWAYAT (History)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: _NeoNavTabItem(
                    label: 'RIWAYAT',
                    icon: AppIcons.receiptLong,
                    isActive: activeTab == NeoNavTab.history,
                    onTap: () => onTabSelected(NeoNavTab.history),
                  ),
                ),
              ),

              // 5. PROFIL (Profile)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: _NeoNavTabItem(
                    label: 'PROFIL',
                    icon: AppIcons.person,
                    isActive: activeTab == NeoNavTab.profile,
                    onTap: () => onTabSelected(NeoNavTab.profile),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Regular navigation item with tactile feedback and refined active state
class _NeoNavTabItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NeoNavTabItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NeoNavTabItem> createState() => _NeoNavTabItemState();
}

class _NeoNavTabItemState extends State<_NeoNavTabItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final translateOffset = _isPressed ? const Offset(1, 1) : Offset.zero;

    return Semantics(
      button: true,
      label: widget.label,
      selected: widget.isActive,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: Transform.translate(
          offset: translateOffset,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
            decoration: BoxDecoration(
              color: widget.isActive ? NeoTokens.lime : Colors.transparent,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: widget.isActive ? NeoTokens.ink : Colors.transparent,
                width: 1.8,
              ),
              boxShadow: widget.isActive && !_isPressed
                  ? const [
                      BoxShadow(
                        color: NeoTokens.ink,
                        offset: Offset(1.5, 1.5),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: AppIcons.sizeControl,
                  color: widget.isActive
                      ? NeoTokens.ink
                      : NeoTokens.inkSecondary,
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: widget.isActive
                          ? FontWeight.w900
                          : FontWeight.w700,
                      letterSpacing: -0.2,
                      color: widget.isActive
                          ? NeoTokens.ink
                          : NeoTokens.inkSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Centerpiece Scan Action Button with high-energy silhouette and zero makeshift reticles
class _NeoNavScanButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _NeoNavScanButton({required this.onPressed});

  @override
  State<_NeoNavScanButton> createState() => _NeoNavScanButtonState();
}

class _NeoNavScanButtonState extends State<_NeoNavScanButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final shadowOffset = _isPressed ? Offset.zero : const Offset(1.5, 1.5);
    final translateOffset = _isPressed ? const Offset(1.5, 1.5) : Offset.zero;

    return Semantics(
      button: true,
      label: 'Pindai Makanan',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        behavior: HitTestBehavior.opaque,
        child: Transform.translate(
          offset: translateOffset,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            height: 48,
            decoration: BoxDecoration(
              color: NeoTokens.lime,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: NeoTokens.ink, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: NeoTokens.ink,
                  offset: shadowOffset,
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.qrCodeScanner,
                  size: AppIcons.sizeControl,
                  color: NeoTokens.ink,
                ),
                SizedBox(height: 1),
                Text(
                  'PINDAI',
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                    color: NeoTokens.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
