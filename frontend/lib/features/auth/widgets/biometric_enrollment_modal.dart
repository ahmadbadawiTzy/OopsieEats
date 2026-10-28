import 'package:flutter/material.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';
import 'package:provider/provider.dart';

/// Modal offering first-time optional biometric unlock enrollment after successful login.
class BiometricEnrollmentModal extends StatefulWidget {
  const BiometricEnrollmentModal({super.key});

  /// Displays the enrollment modal as a modal bottom sheet.
  /// Returns `true` if enabled, `false` if skipped.
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BiometricEnrollmentModal(),
    );
  }

  @override
  State<BiometricEnrollmentModal> createState() =>
      _BiometricEnrollmentModalState();
}

class _BiometricEnrollmentModalState extends State<BiometricEnrollmentModal> {
  bool _isEnrolling = false;

  Future<void> _handleEnroll() async {
    setState(() => _isEnrolling = true);
    final auth = context.read<AuthProvider>();

    // Test biometrics with the OS before enabling
    final success = await auth.setBiometricEnabled(true);

    if (!mounted) return;
    setState(() => _isEnrolling = false);

    if (success) {
      NeoSnackBars.success(
        context,
        'Kunci biometrik berhasil diaktifkan untuk akun Anda.',
      );
      Navigator.of(context).pop(true);
    } else {
      NeoSnackBars.error(
        context,
        auth.errorMessage ?? 'Gagal mengaktifkan biometrik.',
      );
      Navigator.of(context).pop(false);
    }
  }

  Future<void> _handleSkip() async {
    final auth = context.read<AuthProvider>();
    await auth.setBiometricPrompted(true);
    if (!mounted) return;
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isFace = auth.hasFace;
    final biometricTitle = isFace ? 'Face Unlock' : 'Sidik Jari';

    return Container(
      decoration: const BoxDecoration(
        color: NeoTokens.canvas,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NeoTokens.radiusLarge),
        ),
        border: Border(
          top: BorderSide(color: NeoTokens.ink, width: NeoTokens.borderWidth),
          left: BorderSide(color: NeoTokens.ink, width: NeoTokens.borderWidth),
          right: BorderSide(color: NeoTokens.ink, width: NeoTokens.borderWidth),
        ),
      ),
      padding: EdgeInsets.only(
        left: NeoTokens.space24,
        right: NeoTokens.space24,
        top: NeoTokens.space20,
        bottom: MediaQuery.of(context).viewInsets.bottom + NeoTokens.space24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: NeoTokens.inkSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: NeoTokens.space20),

          // Hero Icon Badge
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: NeoTokens.lime,
                shape: BoxShape.circle,
                border: Border.all(
                  color: NeoTokens.ink,
                  width: NeoTokens.borderWidth,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: NeoTokens.ink,
                    offset: NeoTokens.shadowOffsetSmall,
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                isFace ? AppIcons.face : AppIcons.fingerprint,
                size: AppIcons.sizeFeature,
                color: NeoTokens.ink,
              ),
            ),
          ),
          const SizedBox(height: NeoTokens.space16),

          // Title
          const Text(
            'Aktifkan login biometrik',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: NeoTokens.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: NeoTokens.space8),

          // Subtitle description
          const Text(
            'Gunakan keamanan perangkat untuk membuka NutriView dengan lebih praktis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: NeoTokens.inkSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: NeoTokens.space20),

          // Benefit Points Container
          NeoCard(
            backgroundColor: NeoTokens.paper,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            shadowOffset: NeoTokens.shadowOffsetSmall,
            child: Column(
              children: [
                _benefitRow(
                  icon: AppIcons.checkCircle,
                  title: 'Akses Cepat & Nyaman',
                  subtitle:
                      'Buka aplikasi langsung menggunakan $biometricTitle Anda.',
                ),
                const SizedBox(height: NeoTokens.space12),
                _benefitRow(
                  icon: AppIcons.lock,
                  title: 'Aman & Terikat Akun',
                  subtitle:
                      'Hanya berlaku untuk sesi akun ini di perangkat Anda.',
                ),
              ],
            ),
          ),
          const SizedBox(height: NeoTokens.space20),

          // Action: Enable Biometrics
          NeoButton(
            text: 'Aktifkan Biometrik',
            isLoading: _isEnrolling,
            prefixIcon: isFace ? AppIcons.face : AppIcons.fingerprint,
            customBackgroundColor: NeoTokens.lime,
            onPressed: _isEnrolling ? null : _handleEnroll,
          ),
          const SizedBox(height: NeoTokens.space8),

          // Action: Skip / Not Now
          TextButton(
            onPressed: _isEnrolling ? null : _handleSkip,
            child: const Text(
              'Nanti Saja',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: NeoTokens.inkSecondary,
              ),
            ),
          ),
          const SizedBox(height: NeoTokens.space4),

          // Safety clarification
          const Text(
            'Dapat diaktifkan atau dinonaktifkan kapan saja melalui menu Pengaturan Profil.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: NeoTokens.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _benefitRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppIcons.sizeControl, color: NeoTokens.ink),
        const SizedBox(width: NeoTokens.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: NeoTokens.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: NeoTokens.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
