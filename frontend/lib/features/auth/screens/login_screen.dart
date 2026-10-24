import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/shared/neo/neo_badge.dart';
import 'package:nutriview/shared/neo/neo_card.dart';
import 'package:nutriview/shared/widgets/custom_button.dart';
import 'package:nutriview/shared/widgets/custom_text_field.dart';

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
      if (user.isAdmin) {
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
                  // Neo Hero Badge
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: NeoTokens.mintGreen,
                        borderRadius: BorderRadius.circular(
                          NeoTokens.radiusMedium,
                        ),
                        border: Border.all(
                          color: NeoTokens.black,
                          width: NeoTokens.borderWidth,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: NeoTokens.black,
                            offset: NeoTokens.shadowOffset,
                            blurRadius: NeoTokens.shadowBlurRadius,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 44,
                        color: NeoTokens.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space16),
                  const Center(
                    child: NeoBadge(
                      label: 'NUTRITION INTELLIGENCE',
                      color: NeoBadgeColor.yellow,
                      hasShadow: true,
                    ),
                  ),
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
                      fontSize: 13.5,
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
                            Icons.error_outline_rounded,
                            color: NeoTokens.white,
                            size: 22,
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
                        CustomTextField(
                          label: 'Email',
                          controller: _emailController,
                          hintText: 'nama@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            size: 20,
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
                        CustomTextField(
                          label: 'Kata Sandi',
                          controller: _passwordController,
                          hintText: 'Minimal 8 karakter',
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                            color: NeoTokens.black,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                              color: NeoTokens.black,
                            ),
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
                        CustomButton(
                          text: 'Masuk',
                          isLoading: auth.isLoading,
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
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: NeoTokens.textMuted,
                          ),
                        ),
                        const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: NeoTokens.black,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
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
