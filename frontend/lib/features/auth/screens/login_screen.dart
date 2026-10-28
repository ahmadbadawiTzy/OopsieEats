import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';
import 'package:nutriview/core/app_icons.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final user = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (user != null && mounted) {
      final isAdmin =
          user.isAdmin ||
          auth.isAdmin ||
          user.role.toLowerCase().trim() == 'admin' ||
          auth.role.toLowerCase().trim() == 'admin';

      if (isAdmin) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.adminDashboard,
          arguments: {
            'email': user.email,
            'role': user.role,
            'name': user.fullName,
          },
        );
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

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
                  // Neo Hero Brand Logo Mark (Apple mark matching Splash View & App Icon)
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

                  // Error Banner
                  if (auth.errorMessage != null) ...[
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
                                color: NeoTokens.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space16),
                  ],

                  // Form Container
                  NeoCard(
                    backgroundColor: NeoTokens.white,
                    padding: const EdgeInsets.all(NeoTokens.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NeoInput(
                          label: 'Email',
                          controller: _emailController,
                          hintText: 'nama@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(
                            AppIcons.email,
                            size: AppIcons.sizeControl,
                            color: NeoTokens.black,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Email wajib diisi.';
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return 'Format email tidak valid.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: NeoTokens.space16),
                        NeoInput(
                          label: 'Kata Sandi',
                          controller: _passwordController,
                          hintText: 'Minimal 8 karakter',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(
                            AppIcons.lock,
                            size: AppIcons.sizeControl,
                            color: NeoTokens.black,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? AppIcons.visibilityOff
                                  : AppIcons.visibility,
                              size: AppIcons.sizeControl,
                              color: NeoTokens.black,
                            ),
                            tooltip: _obscurePassword
                                ? 'Tampilkan kata sandi'
                                : 'Sembunyikan kata sandi',
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Kata sandi wajib diisi.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: NeoTokens.space24),
                        NeoButton(
                          text: 'Masuk',
                          isLoading: auth.isLoading,
                          customBackgroundColor: NeoTokens.vividYellow,
                          onPressed: _handleLogin,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: NeoTokens.space24),

                  // Registration CTA Card
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}
