import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/profile/widgets/unified_biodata_form.dart';
import 'package:oopsieeats/shared/neo/neo.dart';

/// Screen for completing user physical profile and biometric baseline right
/// after registration or Google sign-in.
///
/// This screen is a mandatory gatekeeper:
/// - No "Skip" or "Later" option is permitted because NutriView requires physical
///   metrics to calculate Basal Metabolic Rate (BMR) and Total Daily Energy Expenditure (TDEE).
/// - Wrapped in PopScope(canPop: false) to prevent bypassing onboarding.
/// - Uses [UnifiedBiodataForm] in [BiodataFormMode.onboarding] to guarantee 100% visual,
///   layout, and architectural parity with the Biodata management screen.
class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await NeoDialog.show(
      context,
      title: 'Keluar dari Sesi?',
      message: 'Pengisian biodata wajib diselesaikan agar OopsieEats dapat mengestimasi kalori. Keluar sekarang akan membatalkan sesi masuk Anda.',
      confirmText: 'Ya, Keluar',
      cancelText: 'Lanjutkan Pengisian',
      confirmColor: NeoTokens.alert,
      icon: AppIcons.logout,
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleLogout(context);
      },
      child: Scaffold(
        backgroundColor: NeoTokens.warmBackground,
        appBar: AppBar(
          backgroundColor: NeoTokens.warmBackground,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Lengkapi Profil Fisik',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: NeoTokens.black,
              letterSpacing: -0.3,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(NeoTokens.borderWidth),
            child: Container(
              color: NeoTokens.black,
              height: NeoTokens.borderWidth,
            ),
          ),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            NeoTokens.space20,
            NeoTokens.space20,
            NeoTokens.space20,
            NeoTokens.space32 + bottomInset,
          ),
          child: UnifiedBiodataForm(
            mode: BiodataFormMode.onboarding,
            onSavedSuccessfully: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.dashboard,
                (route) => false,
              );
            },
            onCancelOrExit: () => _handleLogout(context),
          ),
        ),
      ),
    );
  }
}
