import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/features/splash/widgets/neo_splash_badge.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    final user = await auth.register(
      _emailController.text.trim().toLowerCase(),
      _passwordController.text,
      _nameController.text.trim(),
    );

    if (user != null && mounted) {
      // Direct new user to fill their profile
      Navigator.pushReplacementNamed(context, AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        backgroundColor: NeoTokens.warmBackground,
        elevation: 0,
        leading: NeoBackButton.leading(context),
        title: const Text(
          'Daftar Akun NutriView',
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: NeoTokens.space24,
              vertical: NeoTokens.space20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // NutriView Brand Logo Mark
                  const Center(child: NutriViewLogoMark(size: 64)),
                  const SizedBox(height: NeoTokens.space12),
                  const Text(
                    'Mulai Perjalanan Gizi Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space8),
                  const Text(
                    'Daftar untuk memantau asupan gizi harian secara mudah',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: NeoTokens.textMuted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space24),

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
                                color: NeoTokens.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space16),
                  ],

                  // Form Container Card
                  NeoCard(
                    backgroundColor: NeoTokens.white,
                    padding: const EdgeInsets.all(NeoTokens.space20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Data Akun',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: NeoTokens.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: NeoTokens.space4),
                        const Text(
                          'Lengkapi informasi berikut untuk memulai langkah sehat Anda.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: NeoTokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: NeoTokens.space20),

                        NeoInput(
                          label: 'Nama Lengkap',
                          controller: _nameController,
                          hintText: 'Masukkan nama lengkap',
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          autofillHints: const [AutofillHints.name],
                          prefixIcon: const Icon(
                            AppIcons.personOutline,
                            size: AppIcons.sizeControl,
                            color: NeoTokens.black,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Nama lengkap wajib diisi.';
                            }
                            if (val.trim().length < 2) {
                              return 'Nama lengkap minimal 2 karakter.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: NeoTokens.space16),

                        NeoInput(
                          label: 'Email',
                          controller: _emailController,
                          hintText: 'nama@example.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          prefixIcon: const Icon(
                            AppIcons.email,
                            size: AppIcons.sizeControl,
                            color: NeoTokens.black,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Email wajib diisi.';
                            }
                            final cleanEmail = val.trim();
                            if (!cleanEmail.contains('@') ||
                                !cleanEmail.contains('.')) {
                              return 'Format email tidak valid.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: NeoTokens.space16),

                        NeoInput(
                          label: 'Kata Sandi',
                          controller: _passwordController,
                          hintText: 'Minimal 8 karakter, huruf & angka',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.newPassword],
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
                            if (val.length < 8) {
                              return 'Kata sandi minimal 8 karakter.';
                            }
                            if (!RegExp(r'[A-Za-z]').hasMatch(val) ||
                                !RegExp(r'[0-9]').hasMatch(val)) {
                              return 'Kata sandi harus mengandung kombinasi huruf dan angka.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _handleRegister(),
                        ),
                        const SizedBox(height: NeoTokens.space6),

                        const Padding(
                          padding: EdgeInsets.only(left: NeoTokens.space4),
                          child: Text(
                            'Minimal 8 karakter dengan kombinasi huruf dan angka.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: NeoTokens.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: NeoTokens.space24),

                        NeoButton(
                          text: 'Daftar Akun',
                          isLoading: auth.isLoading,
                          customBackgroundColor: NeoTokens.vividYellow,
                          onPressed: auth.isLoading ? null : _handleRegister,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: NeoTokens.space20),

                  // Bottom Card to switch back to Login
                  NeoCard(
                    backgroundColor: NeoTokens.surfaceMuted,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shadowOffset: NeoTokens.shadowOffsetSmall,
                    onTap: auth.isLoading
                        ? null
                        : () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.login,
                              );
                            }
                          },
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: const [
                        Text(
                          'Sudah memiliki akun? ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: NeoTokens.textMuted,
                          ),
                        ),
                        Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 14,
                            color: NeoTokens.black,
                            fontWeight: FontWeight.w900,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          AppIcons.login,
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
