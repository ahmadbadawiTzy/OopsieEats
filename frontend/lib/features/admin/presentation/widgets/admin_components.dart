import 'package:flutter/material.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/shared/neo/neo.dart';

/// Centralized Reusable Neo-Brutalism Admin Components.
/// Provides a unified, high-contrast, tactile design system for the NutriView Admin Portal.

/// 1. AdminStatusBadge — Color-coded Neo-Brutalism badge for statuses and roles
class AdminStatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const AdminStatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = NeoTokens.ink,
    this.fontSize = 10,
  });

  factory AdminStatusBadge.active() =>
      const AdminStatusBadge(label: 'AKTIF', backgroundColor: NeoTokens.lime);

  factory AdminStatusBadge.inactive() => const AdminStatusBadge(
    label: 'NONAKTIF',
    backgroundColor: NeoTokens.alert,
    textColor: NeoTokens.paper,
  );

  factory AdminStatusBadge.published() =>
      const AdminStatusBadge(label: 'TERBIT', backgroundColor: NeoTokens.lime);

  factory AdminStatusBadge.draft() =>
      const AdminStatusBadge(label: 'DRAFT', backgroundColor: NeoTokens.hazard);

  factory AdminStatusBadge.admin() =>
      const AdminStatusBadge(label: 'ADMIN', backgroundColor: NeoTokens.hazard);

  factory AdminStatusBadge.user() =>
      const AdminStatusBadge(label: 'USER', backgroundColor: NeoTokens.recess);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        border: Border.all(
          color: NeoTokens.ink,
          width: NeoTokens.borderWidthThin,
        ),
        boxShadow: const [
          BoxShadow(
            color: NeoTokens.ink,
            offset: Offset(1.5, 1.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// 2. AdminActionButton — Dedicated single action button for cards and toolbars
class AdminActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const AdminActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.backgroundColor = NeoTokens.paper,
    this.iconColor = NeoTokens.ink,
    this.size = 36,
  });

  factory AdminActionButton.more({
    required VoidCallback onPressed,
    String tooltip = 'Menu Aksi & Detail',
  }) {
    return AdminActionButton(
      icon: AppIcons.moreVert,
      tooltip: tooltip,
      onPressed: onPressed,
    );
  }

  factory AdminActionButton.manage({
    required VoidCallback onPressed,
    String tooltip = 'Kelola Entitas',
  }) {
    return AdminActionButton(
      icon: AppIcons.manageSearch,
      tooltip: tooltip,
      onPressed: onPressed,
      backgroundColor: NeoTokens.lime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        border: Border.all(
          color: NeoTokens.ink,
          width: NeoTokens.borderWidthThin,
        ),
        boxShadow: const [
          BoxShadow(
            color: NeoTokens.ink,
            offset: Offset(1.5, 1.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: IconButton(
        constraints: BoxConstraints(minWidth: size, minHeight: size),
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: AppIcons.sizeControl, color: iconColor),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }
}

/// 3. AdminPageHeader — Standardized page header for all admin sections
class AdminPageHeader extends StatelessWidget {
  final String sectionTag;
  final String title;
  final String? subtitle;
  final Widget? action;

  const AdminPageHeader({
    super.key,
    required this.sectionTag,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NeoTokens.paper,
      padding: const EdgeInsets.symmetric(
        horizontal: NeoTokens.space16,
        vertical: NeoTokens.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sectionTag.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.inkSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.ink,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: NeoTokens.inkSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: NeoTokens.space12),
                action!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// 4. AdminContentContainer — Responsive max-width wrapper
class AdminContentContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const AdminContentContainer({
    super.key,
    required this.child,
    this.maxWidth = 1400.0,
    this.padding = const EdgeInsets.all(NeoTokens.space16),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// 5. AdminFormSection — Structured Neo-Brutalist form section card
class AdminFormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> children;

  const AdminFormSection({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: NeoTokens.paper,
      padding: const EdgeInsets.all(NeoTokens.space16),
      margin: const EdgeInsets.only(bottom: NeoTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppIcons.sizeLarge, color: NeoTokens.ink),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.ink,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: NeoTokens.inkSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space12),
          const Divider(color: NeoTokens.ink, thickness: 1.5, height: 1.5),
          const SizedBox(height: NeoTokens.space12),
          ...children,
        ],
      ),
    );
  }
}

/// 6. AdminEmptyState — High-contrast empty state view
class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onAction;

  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(NeoTokens.space24),
        child: NeoCard(
          backgroundColor: NeoTokens.paper,
          padding: const EdgeInsets.all(NeoTokens.space24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: NeoTokens.hazard,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  border: Border.all(
                    color: NeoTokens.ink,
                    width: NeoTokens.borderWidth,
                  ),
                  boxShadow: NeoTokens.neoBoxShadowSmall(),
                ),
                child: Icon(
                  icon,
                  size: AppIcons.sizeState,
                  color: NeoTokens.ink,
                ),
              ),
              const SizedBox(height: NeoTokens.space16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: NeoTokens.ink,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: NeoTokens.space8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: NeoTokens.inkSecondary,
                  height: 1.4,
                ),
              ),
              if (buttonText != null && onAction != null) ...[
                const SizedBox(height: NeoTokens.space16),
                NeoButton(
                  text: buttonText!,
                  variant: NeoButtonVariant.primary,
                  onPressed: onAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 7. AdminLoadingState — Neo-Brutalist loading indicator
class AdminLoadingState extends StatelessWidget {
  final String message;

  const AdminLoadingState({super.key, this.message = 'Memuat data sistem...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NeoTokens.paper,
              borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
              border: Border.all(
                color: NeoTokens.ink,
                width: NeoTokens.borderWidth,
              ),
              boxShadow: NeoTokens.neoBoxShadowSmall(),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(NeoTokens.ink),
            ),
          ),
          const SizedBox(height: NeoTokens.space12),
          Text(
            message,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: NeoTokens.ink,
            ),
          ),
        ],
      ),
    );
  }
}

/// 8. AdminErrorState — Neo-Brutalist error state card
class AdminErrorState extends StatelessWidget {
  final String title;
  final String errorMessage;
  final VoidCallback? onRetry;

  const AdminErrorState({
    super.key,
    this.title = 'Terjadi Kesalahan',
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(NeoTokens.space24),
        child: NeoCard(
          backgroundColor: NeoTokens.paper,
          padding: const EdgeInsets.all(NeoTokens.space20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: NeoTokens.alert,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  border: Border.all(
                    color: NeoTokens.ink,
                    width: NeoTokens.borderWidth,
                  ),
                  boxShadow: NeoTokens.neoBoxShadowSmall(),
                ),
                child: const Icon(
                  AppIcons.error,
                  size: AppIcons.sizeState,
                  color: NeoTokens.paper,
                ),
              ),
              const SizedBox(height: NeoTokens.space14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: NeoTokens.ink,
                ),
              ),
              const SizedBox(height: NeoTokens.space6),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: NeoTokens.inkSecondary,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: NeoTokens.space16),
                NeoButton(
                  text: 'Coba Lagi',
                  prefixIcon: AppIcons.refresh,
                  variant: NeoButtonVariant.secondary,
                  onPressed: onRetry,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 9. AdminConfirmDialog — Destructive / Important Action Confirmation Dialog
class AdminConfirmDialog {
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Ya, Eksekusi',
    String cancelText = 'Batal',
    bool isDanger = true,
  }) {
    return NeoDialog.show(
      context,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: isDanger ? NeoTokens.alert : NeoTokens.lime,
      icon: isDanger ? AppIcons.warning : AppIcons.infoOutline,
    );
  }
}
