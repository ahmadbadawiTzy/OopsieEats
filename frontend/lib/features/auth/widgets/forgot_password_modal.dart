import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';

/// Tactile Neo-Brutalist modal bottom sheet for requesting a secure
/// Firebase Authentication password reset action link.
class ForgotPasswordModal extends StatefulWidget {
  final String? initialEmail;

  const ForgotPasswordModal({super.key, this.initialEmail});

  static Future<void> show(BuildContext context, {String? initialEmail}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ForgotPasswordModal(initialEmail: initialEmail),
    );
  }

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.sendPasswordResetEmail(
      _emailController.text.trim(),
    );

    if (success && mounted) {
      setState(() {
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: NeoTokens.space24,
        right: NeoTokens.space24,
        top: NeoTokens.space20,
        bottom: NeoTokens.space28 + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: NeoTokens.warmBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NeoTokens.radiusLarge),
        ),
        border: Border(
          top: BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidthThick,
          ),
          left: BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidthThick,
          ),
          right: BorderSide(
            color: NeoTokens.black,
            width: NeoTokens.borderWidthThick,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Drag Handle
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: NeoTokens.black,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: NeoTokens.space16),

              // Title Row with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lupa Kata Sandi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      AppIcons.close,
                      size: AppIcons.sizeToolbar,
                      color: NeoTokens.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Tutup',
                  ),
                ],
              ),
              const SizedBox(height: NeoTokens.space8),

              if (_isSuccess) ...[
                // Professional Confirmation Card (Anti-Account Enumeration Compliant)
                NeoCard(
                  backgroundColor: NeoTokens.lime,
                  padding: const EdgeInsets.all(NeoTokens.space16),
                  shadowOffset: NeoTokens.shadowOffsetSmall,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            AppIcons.checkCircle,
                            size: AppIcons.sizeHeader,
                            color: NeoTokens.black,
                          ),
                          SizedBox(width: NeoTokens.space8),
                          Text(
                            'Instruksi Terkirim',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: NeoTokens.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NeoTokens.space12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: NeoTokens.space12,
                          vertical: NeoTokens.space8,
                        ),
                        decoration: BoxDecoration(
                          color: NeoTokens.paper,
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                          border: Border.all(
                            color: NeoTokens.black,
                            width: NeoTokens.borderWidthThin,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              AppIcons.email,
                              size: AppIcons.sizeMedium,
                              color: NeoTokens.black,
                            ),
                            const SizedBox(width: NeoTokens.space8),
                            Expanded(
                              child: Text(
                                _emailController.text.trim(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: NeoTokens.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: NeoTokens.space12),
                      const Text(
                        'Jika email tersebut terhubung dengan akun yang valid, instruksi pemulihan kata sandi telah dikirim. Silakan periksa kotak masuk dan folder spam email Anda.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: NeoTokens.black,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: NeoTokens.space12),
                      Container(
                        padding: const EdgeInsets.all(NeoTokens.space10),
                        decoration: BoxDecoration(
                          color: NeoTokens.warmBackground,
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                          border: Border.all(
                            color: NeoTokens.black,
                            width: NeoTokens.borderWidthThin,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Icon(
                              AppIcons.shield,
                              size: AppIcons.sizeMedium,
                              color: NeoTokens.black,
                            ),
                            SizedBox(width: NeoTokens.space8),
                            Expanded(
                              child: Text(
                                'Demi keamanan akun Anda, tautan pemulihan ini hanya berlaku selama 1 jam.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: NeoTokens.black,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NeoTokens.space24),
                NeoButton(
                  text: 'Kembali ke Login',
                  variant: NeoButtonVariant.secondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ] else ...[
                const Text(
                  'Masukkan alamat email akun Anda. Kami akan mengirimkan tautan resmi untuk mengatur ulang kata sandi.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: NeoTokens.textMuted,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: NeoTokens.space20),

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

                NeoInput(
                  label: 'Email Terdaftar',
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
                const SizedBox(height: NeoTokens.space24),
                NeoButton(
                  text: 'Kirim Instruksi Pemulihan',
                  isLoading: auth.isResetPasswordLoading,
                  customBackgroundColor: NeoTokens.vividYellow,
                  onPressed: auth.isResetPasswordLoading ? null : _handleReset,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
