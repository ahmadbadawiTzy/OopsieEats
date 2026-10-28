import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/features/auth/widgets/biometric_enrollment_modal.dart';
import 'package:nutriview/features/auth/widgets/forgot_password_modal.dart';
import 'package:nutriview/features/splash/widgets/neo_splash_badge.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

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
    super.dispose();
  }

  Future<void> _handleBiometricLogin() async {
    final auth = context.read<AuthProvider>();
    final user = await auth.authenticateWithBiometrics();

    if (user != null && mounted) {
      _routePostLogin(user);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final user = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (user != null && mounted) {
      await _checkFirstTimeBiometricEnrollment();
      if (!mounted) return;
      _routePostLogin(user);
    }
  }

  Future<void> _handleGoogleLogin() async {
    final auth = context.read<AuthProvider>();
    final user = await auth.loginWithGoogle(rememberMe: _rememberMe);

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
    final auth = context.read<AuthProvider>();
    final isAdmin =
        user?.isAdmin == true ||
        auth.isAdmin ||
        user?.role?.toString().toLowerCase().trim() == 'admin' ||
        auth.role.toLowerCase().trim() == 'admin';

    final targetRoute = isAdmin
        ? AppRoutes.adminDashboard
        : AppRoutes.dashboard;

    Navigator.pushNamedAndRemoveUntil(
      context,
      targetRoute,
      (route) => false,
      arguments: isAdmin
          ? {
              'email': user?.email ?? auth.email,
              'role': user?.role ?? auth.role,
              'name': user?.fullName ?? auth.name,
            }
          : null,
    );
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
                  const Center(child: NutriViewLogoMark(size: 96)),
                  const SizedBox(height: NeoTokens.space12),
                  const Text(
                    'NutriView',
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

                  // Error Banner (if error message exists)
                  if (auth.errorMessage != null &&
                      auth.errorMessage!.isNotEmpty) ...[
                    NeoCard(
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
                    const SizedBox(height: NeoTokens.space20),
                  ],

                  // Conditional Card: Authenticated Transition vs Biometric Locked vs Standard Identity Login
                  if (isAuthenticated)
                    _buildAuthenticatedTransitionCard(auth)
                  else if (isLocked)
                    _buildBiometricLockedCard(auth)
                  else
                    _buildStandardLoginCard(auth),

                  // Registration CTA Card ONLY on normal unauthenticated login state
                  if (!isLocked && !isAuthenticated) ...[
                    const SizedBox(height: NeoTokens.space24),
                    NeoCard(
                      backgroundColor: NeoTokens.surfaceMuted,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shadowOffset: NeoTokens.shadowOffsetSmall,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: NeoTokens.textMuted,
                            ),
                          ),
                          const Text(
                            'Daftar Sekarang',
                            style: TextStyle(
                              fontSize: 14,
                              color: NeoTokens.black,
                              fontWeight: FontWeight.w900,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            AppIcons.arrowForward,
                            size: AppIcons.sizeMedium,
                            color: NeoTokens.black,
                          ),
                        ],
                      ),
                    ),
                  ],
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
          NeoButton(
            key: const Key('password_fallback_button'),
            text: 'Gunakan Kata Sandi',
            variant: NeoButtonVariant.secondary,
            onPressed: auth.isLoading
                ? null
                : () => auth.unlockWithPasswordInstead(),
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

  /// Card displayed for standard identity login (Email/Password or Google).
  Widget _buildStandardLoginCard(AuthProvider auth) {
    return NeoCard(
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
            'Gunakan akun NutriView Anda untuk melanjutkan',
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

          // Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                key: const Key('remember_me_checkbox'),
                onTap: () {
                  setState(() => _rememberMe = !_rememberMe);
                },
                borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _rememberMe
                              ? NeoTokens.lime
                              : NeoTokens.canvas,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: NeoTokens.black,
                            width: 1.8,
                          ),
                        ),
                        child: _rememberMe
                            ? CustomPaint(
                                size: const Size(14, 14),
                                painter: _NeoCheckPainter(),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ingat Saya',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: NeoTokens.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
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
            ],
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

class _NeoCheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NeoTokens.black
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.74)
      ..lineTo(size.width * 0.78, size.height * 0.26);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
