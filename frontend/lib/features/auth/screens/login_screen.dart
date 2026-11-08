import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/core/routes.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/shared/neo/neo.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/features/auth/widgets/biometric_enrollment_modal.dart';
import 'package:oopsieeats/features/auth/widgets/forgot_password_modal.dart';
import 'package:oopsieeats/features/splash/widgets/neo_splash_badge.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fallbackPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureFallbackPassword = true;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final auth = context.read<AuthProvider>();
        if (auth.lifecycleState == AuthLifecycleState.authenticated &&
            auth.isLoggedIn) {
          _routePostLogin(auth.currentUser);
          return;
        }
        auth.checkBiometricAvailability();
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fallbackPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricLogin() async {
    final auth = context.read<AuthProvider>();
    final user = await auth.authenticateWithBiometrics();

    if (user != null && mounted) {
      _routePostLogin(user);
    }
  }

  Future<void> _handlePasswordFallback() async {
    final password = _fallbackPasswordController.text;
    if (password.isEmpty) {
      NeoSnackBars.error(context, 'Kata sandi wajib diisi.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final user = await auth.verifyPasswordFallback(password);

    if (user != null && mounted) {
      _fallbackPasswordController.clear();
      _routePostLogin(user);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final user = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (user != null && mounted) {
      await _checkFirstTimeBiometricEnrollment();
      if (!mounted) return;
      _routePostLogin(user);
    }
  }

  Future<void> _handleGoogleLogin() async {
    final auth = context.read<AuthProvider>();
    final user = await auth.loginWithGoogle();

    if (user != null && mounted) {
      await _checkFirstTimeBiometricEnrollment();
      if (!mounted) return;
      _routePostLogin(user);
    }
  }

  Future<void> _checkFirstTimeBiometricEnrollment() async {
    final auth = context.read<AuthProvider>();
    if (auth.isBiometricAvailable &&
        !auth.isBiometricEnabled &&
        !auth.hasPromptedBiometric) {
      await BiometricEnrollmentModal.show(context);
    }
  }

  void _routePostLogin(dynamic user) {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    final auth = context.read<AuthProvider>();
    final isAdmin =
        user?.isAdmin == true ||
        auth.isAdmin ||
        user?.role?.toString().toLowerCase().trim() == 'admin' ||
        auth.role.toLowerCase().trim() == 'admin';

    if (isAdmin) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.adminDashboard,
        (route) => false,
        arguments: {
          'email': user?.email ?? auth.email,
          'role': user?.role ?? auth.role,
          'name': user?.fullName ?? auth.name,
        },
      );
      return;
    }

    final isComplete =
        user?.isProfileComplete == true || auth.isProfileComplete;
    final targetRoute = isComplete
        ? AppRoutes.dashboard
        : AppRoutes.completeProfile;

    Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) => false);
  }

  Future<void> _showSwitchAccountDialog(
    BuildContext context,
    AuthProvider auth,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => NeoDialog(
        title: 'Ganti Akun?',
        message: 'Sesi akun saat ini akan ditutup dan Anda dapat masuk dengan akun lain.',
        confirmText: 'Ya, Ganti Akun',
        cancelText: 'Batal',
        confirmColor: NeoTokens.coralRed,
        onConfirm: () => Navigator.of(dialogCtx).pop(true),
        onCancel: () => Navigator.of(dialogCtx).pop(false),
      ),
    );

    if (confirmed == true && mounted) {
      _emailController.clear();
      _passwordController.clear();
      await auth.switchAccount();
    }
  }

  void _showForgotPasswordModal() {
    ForgotPasswordModal.show(
      context,
      initialEmail: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final state = auth.lifecycleState;

    final isLocked =
        auth.isBiometricLocked ||
        state == AuthLifecycleState.biometricAuthenticating;
    final isFallback = auth.isPasswordFallback;
    final isAuthenticated = state == AuthLifecycleState.authenticated;

    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: NeoTokens.space24,
              vertical: NeoTokens.space24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Neo Hero Brand Logo Mark
                  const Center(child: OopsieEatsLogoMark(size: 96)),
                  const SizedBox(height: NeoTokens.space12),
                  const Text(
                    'OopsieEats',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.black,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space8),
                  const Text(
                    'Kenali Makanan & Lacak Asupan Gizi Harian',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: NeoTokens.textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space28),

                  // Error Banner with smooth entrance/exit
                  AnimatedSwitcher(
                    duration: NeoMotion.getDuration(
                      context,
                      NeoMotion.durationShort,
                    ),
                    switchInCurve: NeoMotion.curveDecelerate,
                    switchOutCurve: NeoMotion.curveAccelerate,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          alignment: Alignment.topCenter,
                          child: child,
                        ),
                      );
                    },
                    child:
                        (auth.errorMessage != null &&
                            auth.errorMessage!.isNotEmpty)
                        ? Padding(
                            key: ValueKey(auth.errorMessage),
                            padding: const EdgeInsets.only(
                              bottom: NeoTokens.space20,
                            ),
                            child: NeoCard(
                              backgroundColor: NeoTokens.coralRed,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              shadowOffset: NeoTokens.shadowOffsetSmall,
                              child: Row(
                                children: [
                                  const Icon(
                                    AppIcons.error,
                                    color: NeoTokens.white,
                                    size: AppIcons.sizeToolbar,
                                  ),
                                  const SizedBox(width: NeoTokens.space12),
                                  Expanded(
                                    child: Text(
                                      auth.errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: NeoTokens.white,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('no_error_banner'),
                          ),
                  ),

                  // Conditional Card: Authenticated Transition vs Biometric Locked vs Standard Identity Login
                  AnimatedSwitcher(
                    duration: NeoMotion.getDuration(
                      context,
                      NeoMotion.durationMedium,
                    ),
                    switchInCurve: NeoMotion.curveDecelerate,
                    switchOutCurve: NeoMotion.curveAccelerate,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.04),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(
                        isAuthenticated
                            ? 'auth_transition_subtree'
                            : isLocked
                            ? 'biometric_locked_subtree'
                            : isFallback
                            ? 'password_fallback_subtree'
                            : 'standard_login_subtree',
                      ),
                      child: isAuthenticated
                          ? _buildAuthenticatedTransitionCard(auth)
                          : isLocked
                          ? _buildBiometricLockedCard(auth)
                          : isFallback
                          ? _buildPasswordFallbackCard(auth)
                          : _buildStandardLoginCard(auth),
                    ),
                  ),

                  // Registration CTA Card ONLY on normal unauthenticated login state
                  AnimatedSwitcher(
                    duration: NeoMotion.getDuration(
                      context,
                      NeoMotion.durationShort,
                    ),
                    switchInCurve: NeoMotion.curveDecelerate,
                    switchOutCurve: NeoMotion.curveAccelerate,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          alignment: Alignment.topCenter,
                          child: child,
                        ),
                      );
                    },
                    child: (!isLocked && !isFallback && !isAuthenticated)
                        ? Padding(
                            key: const ValueKey('registration_cta_card'),
                            padding: const EdgeInsets.only(
                              top: NeoTokens.space24,
                            ),
                            child: NeoCard(
                              backgroundColor: NeoTokens.surfaceMuted,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shadowOffset: NeoTokens.shadowOffsetSmall,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.register,
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Belum punya akun? ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: NeoTokens.textMuted,
                                    ),
                                  ),
                                  Text(
                                    'Daftar Sekarang',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: NeoTokens.black,
                                      fontWeight: FontWeight.w900,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    AppIcons.arrowForward,
                                    size: AppIcons.sizeMedium,
                                    color: NeoTokens.black,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('registration_cta_empty'),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Card displayed when session is successfully validated and the app is navigating to dashboard.
  Widget _buildAuthenticatedTransitionCard(AuthProvider auth) {
    final name = auth.name.isNotEmpty
        ? auth.name
        : (auth.email.isNotEmpty ? auth.email : 'Pengguna');

    return NeoCard(
      key: const Key('authenticated_transition_card'),
      backgroundColor: NeoTokens.white,
      padding: const EdgeInsets.all(NeoTokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: NeoTokens.lime,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  border: Border.all(
                    color: NeoTokens.black,
                    width: NeoTokens.borderWidth,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: NeoTokens.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  AppIcons.checkCircle,
                  color: NeoTokens.black,
                  size: AppIcons.sizeState,
                ),
              ),
              const SizedBox(width: NeoTokens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: NeoTokens.lime,
                        borderRadius: BorderRadius.circular(
                          NeoTokens.radiusSmall,
                        ),
                        border: Border.all(color: NeoTokens.black, width: 1.5),
                      ),
                      child: const Text(
                        'TERVERIFIKASI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: NeoTokens.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space20),
          Container(
            padding: const EdgeInsets.all(NeoTokens.space12),
            decoration: BoxDecoration(
              color: NeoTokens.surfaceMuted,
              borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
              border: Border.all(color: NeoTokens.black, width: 1.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(NeoTokens.black),
                  ),
                ),
                SizedBox(width: NeoTokens.space12),
                Text(
                  'Memuat Beranda...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: NeoTokens.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Card displayed when an authenticated session is protected by biometric gatekeeper.
  Widget _buildBiometricLockedCard(AuthProvider auth) {
    final name = auth.name.isNotEmpty ? auth.name : auth.email;
    final isFace = auth.hasFace;
    final biometricLabel = isFace
        ? 'Buka dengan Wajah'
        : (auth.hasFingerprint
              ? 'Buka dengan Sidik Jari'
              : 'Buka dengan Biometrik');

    return NeoCard(
      key: const Key('biometric_locked_card'),
      backgroundColor: NeoTokens.white,
      padding: const EdgeInsets.all(NeoTokens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: NeoTokens.lime,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  border: Border.all(
                    color: NeoTokens.black,
                    width: NeoTokens.borderWidth,
                  ),
                ),
                child: Icon(
                  isFace ? AppIcons.face : AppIcons.fingerprint,
                  color: NeoTokens.black,
                  size: AppIcons.sizeToolbar,
                ),
              ),
              const SizedBox(width: NeoTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang Kembali',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: NeoTokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space16),
          const Text(
            'Sesi Anda tersimpan dan dilindungi oleh autentikasi biometrik.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: NeoTokens.textMuted,
              height: 1.3,
            ),
          ),
          const SizedBox(height: NeoTokens.space20),
          NeoButton(
            key: const Key('biometric_unlock_button'),
            text: biometricLabel,
            isLoading:
                auth.isBiometricLoading || auth.isBiometricAuthenticating,
            prefixIcon: isFace ? AppIcons.face : AppIcons.fingerprint,
            customBackgroundColor: NeoTokens.lime,
            onPressed: (auth.isLoading || auth.isBiometricLoading)
                ? null
                : _handleBiometricLogin,
          ),
          const SizedBox(height: NeoTokens.space12),
          if (auth.hasGoogleProvider && !auth.hasPasswordProvider)
            NeoButton(
              key: const Key('google_fallback_button'),
              text: 'Masuk dengan Akun Google',
              variant: NeoButtonVariant.secondary,
              prefixWidget: Image.asset(
                'assets/images/google_logo.png',
                width: AppIcons.sizeControl,
                height: AppIcons.sizeControl,
              ),
              isLoading: auth.isGoogleLoading,
              onPressed: auth.isLoading ? null : _handleGoogleLogin,
            )
          else
            NeoButton(
              key: const Key('password_fallback_button'),
              text: 'Gunakan Kata Sandi',
              variant: NeoButtonVariant.secondary,
              onPressed: auth.isLoading
                  ? null
                  : () {
                      _fallbackPasswordController.clear();
                      auth.switchToPasswordFallback();
                    },
            ),
          const SizedBox(height: NeoTokens.space12),
          Center(
            child: TextButton(
              key: const Key('switch_account_button'),
              onPressed: auth.isLoading
                  ? null
                  : () => _showSwitchAccountDialog(context, auth),
              child: const Text(
                'Ganti Akun',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: NeoTokens.textMuted,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card displayed when user chooses to unlock their existing biometric-protected session with password.
  Widget _buildPasswordFallbackCard(AuthProvider auth) {
    final knownName = auth.name.isNotEmpty ? auth.name : 'Pengguna';
    final knownEmail = auth.email;

    return NeoCard(
      key: const Key('password_fallback_card'),
      backgroundColor: NeoTokens.white,
      padding: const EdgeInsets.all(NeoTokens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: NeoTokens.hazard,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  border: Border.all(
                    color: NeoTokens.black,
                    width: NeoTokens.borderWidth,
                  ),
                ),
                child: const Icon(
                  AppIcons.lock,
                  color: NeoTokens.black,
                  size: AppIcons.sizeToolbar,
                ),
              ),
              const SizedBox(width: NeoTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buka dengan Kata Sandi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Konfirmasi kata sandi untuk akun Anda',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: NeoTokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space16),

          // Account context banner: Name & known email
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: NeoTokens.recess,
              borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
              border: Border.all(
                color: NeoTokens.black,
                width: NeoTokens.borderWidthThin,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  AppIcons.person,
                  size: AppIcons.sizeControl,
                  color: NeoTokens.black,
                ),
                const SizedBox(width: NeoTokens.space10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        knownName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: NeoTokens.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (knownEmail.isNotEmpty)
                        Text(
                          knownEmail,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: NeoTokens.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: NeoTokens.paper,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                    border: Border.all(color: NeoTokens.black, width: 1.0),
                  ),
                  child: const Text(
                    'SESI AKTIF',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: NeoTokens.space16),

          // Password field
          TextFormField(
            key: const Key('fallback_password_field'),
            controller: _fallbackPasswordController,
            obscureText: _obscureFallbackPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handlePasswordFallback(),
            decoration: InputDecoration(
              labelText: 'Kata Sandi',
              hintText: 'Masukkan kata sandi akun',
              prefixIcon: const Icon(AppIcons.lock, size: AppIcons.sizeControl),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureFallbackPassword
                      ? AppIcons.visibilityOff
                      : AppIcons.visibility,
                  size: AppIcons.sizeControl,
                ),
                onPressed: () {
                  setState(() {
                    _obscureFallbackPassword = !_obscureFallbackPassword;
                  });
                },
              ),
              filled: true,
              fillColor: NeoTokens.canvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                borderSide: const BorderSide(
                  color: NeoTokens.black,
                  width: NeoTokens.borderWidth,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                borderSide: const BorderSide(
                  color: NeoTokens.black,
                  width: NeoTokens.borderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                borderSide: const BorderSide(
                  color: NeoTokens.black,
                  width: NeoTokens.borderWidthThick,
                ),
              ),
            ),
          ),
          const SizedBox(height: NeoTokens.space8),

          // Forgot password link for fallback
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              key: const Key('fallback_forgot_password_button'),
              onPressed: auth.isLoading
                  ? null
                  : () {
                      ForgotPasswordModal.show(
                        context,
                        initialEmail: knownEmail,
                      );
                    },
              child: const Text(
                'Lupa Kata Sandi?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: NeoTokens.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: NeoTokens.space12),

          // Submit button
          NeoButton(
            key: const Key('verify_fallback_password_button'),
            text: 'Verifikasi & Buka Sesi',
            isLoading: auth.isLoading,
            prefixIcon: AppIcons.login,
            customBackgroundColor: NeoTokens.hazard,
            onPressed: auth.isLoading ? null : _handlePasswordFallback,
          ),
          const SizedBox(height: NeoTokens.space12),

          // Return to biometric button (if available)
          if (auth.isBiometricEligible) ...[
            NeoButton(
              key: const Key('return_to_biometric_button'),
              text: auth.hasFace
                  ? 'Kembali ke Face Unlock'
                  : 'Kembali ke Sidik Jari',
              variant: NeoButtonVariant.secondary,
              prefixIcon: auth.hasFace ? AppIcons.face : AppIcons.fingerprint,
              onPressed: auth.isLoading
                  ? null
                  : () {
                      _fallbackPasswordController.clear();
                      auth.returnToBiometricLock();
                    },
            ),
            const SizedBox(height: NeoTokens.space12),
          ],

          // Switch account
          Center(
            child: TextButton(
              key: const Key('fallback_switch_account_button'),
              onPressed: auth.isLoading
                  ? null
                  : () => _showSwitchAccountDialog(context, auth),
              child: const Text(
                'Bukan akun Anda? Ganti Akun',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: NeoTokens.textMuted,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card displayed for standard identity login (Email/Password or Google).
  Widget _buildStandardLoginCard(AuthProvider auth) {
    return NeoCard(
      key: const Key('standard_login_card'),
      backgroundColor: NeoTokens.white,
      padding: const EdgeInsets.all(NeoTokens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Masuk ke Akun',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: NeoTokens.black,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: NeoTokens.space4),
          const Text(
            'Gunakan akun OopsieEats Anda untuk melanjutkan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: NeoTokens.textMuted,
            ),
          ),
          const SizedBox(height: NeoTokens.space20),

          // Show biometric unlock shortcut only if eligible for the active local account/session
          if (auth.isBiometricEligible) ...[
            NeoCard(
              key: const Key('return_to_biometric_card'),
              backgroundColor: NeoTokens.lime,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shadowOffset: NeoTokens.shadowOffsetSmall,
              onTap: () => auth.returnToBiometricLock(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    auth.hasFace ? AppIcons.face : AppIcons.fingerprint,
                    size: AppIcons.sizeControl,
                    color: NeoTokens.black,
                  ),
                  const SizedBox(width: NeoTokens.space8),
                  Text(
                    auth.hasFace
                        ? 'Buka dengan Face Unlock'
                        : 'Buka dengan Sidik Jari',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: NeoTokens.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NeoTokens.space16),
          ],

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'nama@email.com',
              prefixIcon: const Icon(
                AppIcons.email,
                size: AppIcons.sizeControl,
              ),
              filled: true,
              fillColor: NeoTokens.canvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                borderSide: const BorderSide(
                  color: NeoTokens.black,
                  width: NeoTokens.borderWidth,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                borderSide: const BorderSide(
                  color: NeoTokens.black,
                  width: NeoTokens.borderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                borderSide: const BorderSide(
                  color: NeoTokens.black,
                  width: NeoTokens.borderWidthThick,
                ),
              ),
            ),
            validator: (v) {
              final val = v?.trim() ?? '';
              if (val.isEmpty) return 'Email wajib diisi.';
              if (!val.contains('@') || !val.contains('.')) {
                return 'Format email tidak valid.';
              }
              return null;
            },
          ),
          const SizedBox(height: NeoTokens.space16),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              labelText: 'Kata Sandi',
              hintText: 'Masukkan kata sandi',
              prefixIcon: const Icon(AppIcons.lock, size: AppIcons.sizeControl),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? AppIcons.visibilityOff
                      : AppIcons.visibility,
                  size: AppIcons.sizeControl,
                ),
                tooltip: _obscurePassword
                    ? 'Tampilkan kata sandi'
                    : 'Sembunyikan kata sandi',
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              filled: true,
              fillColor: NeoTokens.canvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                borderSide: const BorderSide(
                  color: NeoTokens.black,
                  width: NeoTokens.borderWidth,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                borderSide: const BorderSide(
                  color: NeoTokens.black,
                  width: NeoTokens.borderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                borderSide: const BorderSide(
                  color: NeoTokens.black,
                  width: NeoTokens.borderWidthThick,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Kata sandi wajib diisi.';
              return null;
            },
          ),
          const SizedBox(height: NeoTokens.space12),

          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              key: const Key('forgot_password_link'),
              onTap: _showForgotPasswordModal,
              child: const Text(
                'Lupa Password?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: NeoTokens.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const SizedBox(height: NeoTokens.space20),

          // Primary Submit Button
          NeoButton(
            text: 'Masuk',
            isLoading: auth.isEmailLoading,
            customBackgroundColor: NeoTokens.vividYellow,
            onPressed: auth.isLoading ? null : _handleLogin,
          ),
          const SizedBox(height: NeoTokens.space16),

          // Divider
          Row(
            children: [
              const Expanded(
                child: Divider(
                  color: NeoTokens.recess,
                  thickness: NeoTokens.borderWidthThin,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: NeoTokens.space12,
                ),
                child: const Text(
                  'ATAU',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: NeoTokens.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(
                  color: NeoTokens.recess,
                  thickness: NeoTokens.borderWidthThin,
                ),
              ),
            ],
          ),
          const SizedBox(height: NeoTokens.space16),

          // Google Login Button
          NeoButton(
            text: 'Lanjutkan dengan Google',
            isLoading: auth.isGoogleLoading,
            prefixWidget: Image.asset(
              'assets/images/google_logo.png',
              width: AppIcons.sizeControl,
              height: AppIcons.sizeControl,
            ),
            variant: NeoButtonVariant.secondary,
            onPressed: auth.isLoading ? null : _handleGoogleLogin,
          ),
        ],
      ),
    );
  }
}
