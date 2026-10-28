import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/dashboard/providers/dashboard_provider.dart';
import 'package:nutriview/features/meals/providers/meal_history_provider.dart';
import 'package:nutriview/features/profile/providers/profile_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';
import 'package:nutriview/shared/widgets/loading_indicator.dart';
import 'package:nutriview/core/app_icons.dart';

/// Redesigned Profile Screen acting as the central user identity hub:
/// - Prominent centered game avatar character
/// - Clear user identity and dynamic age/gender summary
/// - "Ganti Avatar" button triggering the built-in game character catalog
/// - Dedicated Biodata management entry point
/// - Calculated daily nutritional targets
/// - Direct access to "Tentang Aplikasi & Pembuat"
/// - Account security (Logout & Delete Account)
class ProfileScreen extends StatefulWidget {
  final bool isTab;

  const ProfileScreen({super.key, this.isTab = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _initialized = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProfileProvider>().loadProfile();
      if (mounted) {
        await context.read<AuthProvider>().checkBiometricAvailability();
      }
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  Future<void> _handleToggleBiometric(bool value) async {
    final auth = context.read<AuthProvider>();
    if (value) {
      final success = await auth.setBiometricEnabled(true);
      if (success && mounted) {
        NeoSnackBars.success(context, 'Kunci biometrik berhasil diaktifkan.');
      } else if (mounted) {
        NeoSnackBars.error(
          context,
          auth.errorMessage ?? 'Gagal mengaktifkan biometrik.',
        );
      }
    } else {
      await auth.setBiometricEnabled(false);
      if (mounted) {
        NeoSnackBars.info(context, 'Kunci biometrik dinonaktifkan.');
      }
    }
  }

  Future<void> _openAvatarCatalog(ProfileProvider profileProvider) async {
    final currentAvatarId =
        profileProvider.user?.avatarPreset ?? AvatarCatalog.defaultAvatarId;

    final selectedId = await AvatarSelectionModal.show(
      context,
      currentAvatarId: currentAvatarId,
    );

    if (selectedId != null && selectedId != currentAvatarId && mounted) {
      final success = await profileProvider.updateAvatar(
        avatarPreset: selectedId,
      );
      if (success && mounted) {
        NeoSnackBars.success(
          context,
          'Avatar berhasil diubah ke ${AvatarCatalog.getById(selectedId).name}!',
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await NeoDialog.show(
      context,
      title: 'Keluar dari Akun?',
      message: 'Apakah Anda yakin ingin keluar dari akun NutriView? Anda perlu masuk kembali untuk mengakses data gizi Anda.',
      confirmText: 'Ya, Logout',
      cancelText: 'Batal',
      confirmColor: NeoTokens.alert,
      icon: AppIcons.logout,
    );

    if (confirmed == true && mounted) {
      final auth = context.read<AuthProvider>();
      final nav = Navigator.of(context);
      await auth.logout();
      if (!mounted) return;
      nav.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(NeoTokens.space24),
            decoration: BoxDecoration(
              color: NeoTokens.paper,
              borderRadius: BorderRadius.circular(NeoTokens.radiusLarge),
              border: Border.all(
                color: NeoTokens.black,
                width: NeoTokens.borderWidth,
              ),
              boxShadow: const [
                BoxShadow(
                  color: NeoTokens.black,
                  offset: NeoTokens.shadowOffsetMedium,
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    valueColor: AlwaysStoppedAnimation<Color>(NeoTokens.black),
                  ),
                ),
                const SizedBox(height: NeoTokens.space16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: NeoTokens.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _showReauthPasswordDialog() async {
    final passwordController = TextEditingController();
    bool obscure = true;

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Container(
                padding: const EdgeInsets.all(NeoTokens.space20),
                decoration: BoxDecoration(
                  color: NeoTokens.paper,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusLarge),
                  border: Border.all(
                    color: NeoTokens.black,
                    width: NeoTokens.borderWidth,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: NeoTokens.black,
                      offset: NeoTokens.shadowOffsetMedium,
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: NeoTokens.alert,
                            borderRadius: BorderRadius.circular(
                              NeoTokens.radiusSmall,
                            ),
                            border: Border.all(
                              color: NeoTokens.black,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            AppIcons.lock,
                            size: AppIcons.sizeMedium,
                            color: NeoTokens.paper,
                          ),
                        ),
                        const SizedBox(width: NeoTokens.space12),
                        const Expanded(
                          child: Text(
                            'Konfirmasi Sandi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: NeoTokens.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoTokens.space16),
                    const Text(
                      'Demi keamanan, masukkan kata sandi akun Anda untuk mengonfirmasi penghapusan permanen.',
                      style: TextStyle(
                        fontSize: 13,
                        color: NeoTokens.textMuted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space16),
                    NeoInput(
                      controller: passwordController,
                      label: 'Kata Sandi',
                      hintText: 'Masukkan kata sandi Anda',
                      prefixIcon: const Icon(
                        AppIcons.lock,
                        size: AppIcons.sizeSmall,
                        color: NeoTokens.black,
                      ),
                      obscureText: obscure,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? AppIcons.visibility
                              : AppIcons.visibilityOff,
                          size: AppIcons.sizeSmall,
                          color: NeoTokens.black,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscure = !obscure;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space20),
                    Row(
                      children: [
                        Expanded(
                          child: NeoButton(
                            text: 'Batal',
                            variant: NeoButtonVariant.secondary,
                            onPressed: () => Navigator.of(dialogCtx).pop(null),
                          ),
                        ),
                        const SizedBox(width: NeoTokens.space12),
                        Expanded(
                          child: NeoButton(
                            text: 'Hapus Akun',
                            variant: NeoButtonVariant.danger,
                            onPressed: () {
                              final pwd = passwordController.text;
                              if (pwd.isEmpty) {
                                return;
                              }
                              Navigator.of(dialogCtx).pop(pwd);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleDeleteAccount() async {
    if (_isDeleting) return;

    final confirmed = await NeoDialog.show(
      context,
      title: 'Hapus Akun & Data?',
      message: 'PERINGATAN: Tindakan ini bersifat permanen. Seluruh akun, profil, target gizi, dan riwayat makanan Anda akan dihapus secara permanen dari server.',
      confirmText: 'Hapus Akun',
      cancelText: 'Batal',
      confirmColor: NeoTokens.alert,
      icon: AppIcons.deleteForever,
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);

    _showLoadingDialog('Menghapus akun dan seluruh data...');

    var success = await auth.deleteAccount();

    if (!mounted) return;

    // Handle re-authentication requirement if session is older than 5 minutes
    if (!success && auth.errorCode == 'REQUIRES_RECENT_LOGIN') {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(); // dismiss loading dialog

      final password = await _showReauthPasswordDialog();
      if (!mounted) {
        setState(() => _isDeleting = false);
        return;
      }

      if (password != null && password.isNotEmpty) {
        _showLoadingDialog('Memverifikasi sandi & menghapus akun...');
        success = await auth.deleteAccount(password: password);
        if (!mounted) return;
        Navigator.of(
          context,
          rootNavigator: true,
        ).pop(); // dismiss loading dialog
      } else {
        setState(() => _isDeleting = false);
        return;
      }
    } else {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pop(); // dismiss loading dialog
    }

    if (!mounted) return;
    setState(() {
      _isDeleting = false;
    });

    if (success) {
      // Clear in-memory caches and states
      context.read<ProfileProvider>().clear();
      context.read<MealHistoryProvider>().clear();
      context.read<DashboardProvider>().clear();

      NeoSnackBars.success(context, 'Akun Anda telah berhasil dihapus.');
      nav.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    } else if (auth.errorMessage != null) {
      NeoSnackBars.error(context, auth.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();

    if (!_initialized && profileProvider.isLoading) {
      return const Scaffold(
        backgroundColor: NeoTokens.warmBackground,
        body: LoadingIndicator(message: 'Memuat profil...'),
      );
    }

    final user = profileProvider.user;
    final profile = profileProvider.profile;
    final target = profileProvider.dailyTarget;
    final avatarId = user?.avatarPreset ?? AvatarCatalog.defaultAvatarId;
    final character = AvatarCatalog.getById(avatarId);

    final displayName = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : (user?.email.isNotEmpty == true
              ? user!.email.split('@').first
              : 'Pengguna NutriView');

    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        leading: widget.isTab ? null : NeoBackButton.leading(context),
        elevation: 0,
        backgroundColor: NeoTokens.warmBackground,
        title: const Text(
          'Profil Pengguna',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.4,
            color: NeoTokens.ink,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: NeoTokens.ink, height: 1.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.info, color: NeoTokens.ink),
            tooltip: 'Tentang Aplikasi',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.about),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: NeoTokens.ink,
        backgroundColor: NeoTokens.vividYellow,
        onRefresh: () => profileProvider.loadProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: NeoTokens.space16,
            vertical: NeoTokens.space16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==============================================================
              // 1. CENTERED HERO AVATAR & IDENTITY
              // ==============================================================
              NeoCard(
                backgroundColor: NeoTokens.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: NeoTokens.space20,
                  vertical: NeoTokens.space24,
                ),
                child: Column(
                  children: [
                    // Centered Large Game Avatar
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomRight,
                        children: [
                          NeoAvatar(
                            avatarPreset: avatarId,
                            size: 96,
                            borderWidth: 3.0,
                            shadowOffset: const Offset(4, 4),
                          ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: GestureDetector(
                              onTap: () => _openAvatarCatalog(profileProvider),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: NeoTokens.vividYellow,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: NeoTokens.black,
                                    width: 2,
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
                                  AppIcons.edit,
                                  size: AppIcons.sizeLarge,
                                  color: NeoTokens.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space16),

                    // User Full Name
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.black,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Email & Role
                    Text(
                      user?.email ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: NeoTokens.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Character Name Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: character.backgroundColor,
                        borderRadius: BorderRadius.circular(
                          NeoTokens.radiusSmall,
                        ),
                        border: Border.all(color: NeoTokens.black, width: 1.5),
                      ),
                      child: Text(
                        'Karakter: ${character.name} (${character.title})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: NeoTokens.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Badges row: Social Profession vs Security Role
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // Display Profession Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: NeoTokens.mintGreen,
                            borderRadius: BorderRadius.circular(
                              NeoTokens.radiusSmall,
                            ),
                            border: Border.all(
                              color: NeoTokens.black,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                AppIcons.businessCenter,
                                size: AppIcons.sizeMicro,
                                color: NeoTokens.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Profesi: ${user?.profile?.profession ?? 'Umum'}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: NeoTokens.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Security Role Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: user?.isAdmin == true
                                ? NeoTokens.vividYellow
                                : NeoTokens.white,
                            borderRadius: BorderRadius.circular(
                              NeoTokens.radiusSmall,
                            ),
                            border: Border.all(
                              color: NeoTokens.black,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                user?.isAdmin == true
                                    ? AppIcons.adminPanelSettings
                                    : AppIcons.person,
                                size: AppIcons.sizeMicro,
                                color: NeoTokens.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user?.isAdmin == true ? 'ADMIN' : 'USER',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'monospace',
                                  color: NeoTokens.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoTokens.space16),

                    // "Ganti Avatar" Button
                    SizedBox(
                      width: double.infinity,
                      child: NeoButton(
                        text: 'Pilih Karakter Avatar',
                        variant: NeoButtonVariant.secondary,
                        prefixIcon: AppIcons.theaterComedy,
                        height: 44,
                        onPressed: () => _openAvatarCatalog(profileProvider),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NeoTokens.space16),

              // ==============================================================
              // 2. BIODATA & TARGET NUTRISI SECTION
              // ==============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const NeoSectionHeader(
                    title: 'Biodata & Sasaran Gizi',
                    accentColor: NeoTokens.mintGreen,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final updated = await Navigator.pushNamed(
                        context,
                        AppRoutes.biodata,
                      );
                      if (updated == true && mounted) {
                        profileProvider.loadProfile();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: NeoTokens.vividYellow,
                        borderRadius: BorderRadius.circular(
                          NeoTokens.radiusSmall,
                        ),
                        border: Border.all(color: NeoTokens.black, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: NeoTokens.black,
                            offset: Offset(1.5, 1.5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            profile != null
                                ? AppIcons.editNote
                                : AppIcons.addCircleOutline,
                            size: AppIcons.sizeMedium,
                            color: NeoTokens.black,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile != null ? 'Kelola Biodata' : 'Isi Biodata',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: NeoTokens.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NeoTokens.space8),

              if (profile == null)
                NeoCard(
                  backgroundColor: NeoTokens.white,
                  padding: const EdgeInsets.all(NeoTokens.space20),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: NeoTokens.paper,
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusMedium,
                          ),
                          border: Border.all(color: NeoTokens.black, width: 2),
                        ),
                        child: const Icon(
                          AppIcons.fitnessCenter,
                          color: NeoTokens.black,
                          size: AppIcons.sizeState,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Biodata Fisik Belum Dilengkapi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Lengkapi tanggal lahir, tinggi, dan berat badan agar NutriView dapat menghitung kebutuhan kalori harianmu secara akurat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: NeoTokens.textMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: NeoTokens.space16),
                      NeoButton(
                        text: 'Lengkapi Biodata Sekarang',
                        variant: NeoButtonVariant.primary,
                        prefixIcon: AppIcons.add,
                        onPressed: () async {
                          final updated = await Navigator.pushNamed(
                            context,
                            AppRoutes.biodata,
                          );
                          if (updated == true && mounted) {
                            profileProvider.loadProfile();
                          }
                        },
                      ),
                    ],
                  ),
                )
              else ...[
                // Physical metrics summary
                NeoCard(
                  backgroundColor: NeoTokens.white,
                  padding: const EdgeInsets.all(NeoTokens.space16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _metricBox(
                              label: 'Usia',
                              value: '${profile.calculatedAge}',
                              unit: 'thn',
                              subtext: profile.birthDate != null
                                  ? 'Dari Tgl Lahir'
                                  : 'Perlu Tgl Lahir',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _metricBox(
                              label: 'Gender',
                              value: profile.sex == 'male' ? 'Pria' : 'Wanita',
                              unit: '',
                              subtext: profile.sexLabel,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _metricBox(
                              label: 'Tinggi',
                              value: '${profile.heightCm.toInt()}',
                              unit: 'cm',
                              subtext: 'Tinggi Badan',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _metricBox(
                              label: 'Berat',
                              value: '${profile.weightKg.toInt()}',
                              unit: 'kg',
                              subtext: 'Berat Badan',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: NeoTokens.paper,
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                          border: Border.all(
                            color: NeoTokens.black,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              AppIcons.bolt,
                              size: AppIcons.sizeMedium,
                              color: NeoTokens.black,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${profile.activityLabel} · ${profile.goalLabel}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: NeoTokens.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: NeoTokens.space12),

                // Daily Nutrition Target Card
                if (target != null)
                  NeoCard(
                    backgroundColor: NeoTokens.mintGreen,
                    padding: const EdgeInsets.all(NeoTokens.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Row(
                              children: [
                                Icon(
                                  AppIcons.trackChanges,
                                  size: AppIcons.sizeLarge,
                                  color: NeoTokens.black,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Target Gizi Harian',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: NeoTokens.black,
                                  ),
                                ),
                              ],
                            ),
                            NeoBadge(
                              label: 'MIFFLIN-ST JEOR',
                              color: NeoBadgeColor.yellow,
                              fontSize: 10,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _targetCard(
                                'Kalori',
                                '${target.caloriesKcal}',
                                'kkal',
                                NeoTokens.vividYellow,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _targetCard(
                                'Protein',
                                '${target.proteinG}',
                                'g',
                                NeoTokens.skyBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _targetCard(
                                'Karbo',
                                '${target.carbsG}',
                                'g',
                                NeoTokens.orangeCarb,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _targetCard(
                                'Lemak',
                                '${target.fatG}',
                                'g',
                                NeoTokens.lavender,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: NeoTokens.space20),

              // ==============================================================
              // 3. APP & ACCOUNT ACTIONS MENU
              // ==============================================================
              const NeoSectionHeader(
                title: 'Pengaturan & Informasi',
                accentColor: NeoTokens.lavender,
              ),
              const SizedBox(height: NeoTokens.space8),

              NeoCard(
                backgroundColor: NeoTokens.white,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    if (user?.isAdmin == true) ...[
                      _menuTile(
                        icon: AppIcons.adminPanelSettings,
                        iconColor: NeoTokens.lime,
                        title: 'Portal Admin',
                        subtitle:
                            'Kelola pangan, artikel CMS, pengguna & log sistem',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.adminDashboard,
                        ),
                      ),
                      const Divider(
                        color: NeoTokens.black,
                        height: 1,
                        thickness: 1,
                      ),
                    ],
                    _menuTile(
                      icon: AppIcons.info,
                      iconColor: NeoTokens.skyBlue,
                      title: 'Tentang NutriView & Pembuat',
                      subtitle: 'Profil Ahmad Badawi, tujuan & versi aplikasi',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.about),
                    ),
                    const Divider(
                      color: NeoTokens.black,
                      height: 1,
                      thickness: 1,
                    ),
                    if (auth.isBiometricAvailable) ...[
                      _switchMenuTile(
                        icon: auth.hasFace
                            ? AppIcons.face
                            : AppIcons.fingerprint,
                        iconColor: NeoTokens.lime,
                        title: auth.hasFace
                            ? 'Kunci Wajah (Face Unlock)'
                            : (auth.hasFingerprint
                                  ? 'Kunci Sidik Jari'
                                  : 'Kunci Biometrik'),
                        subtitle:
                            'Buka sesi aplikasi dengan cepat tanpa kata sandi',
                        value: auth.isBiometricEnabled,
                        onChanged: _handleToggleBiometric,
                      ),
                      const Divider(
                        color: NeoTokens.black,
                        height: 1,
                        thickness: 1,
                      ),
                    ],
                    _menuTile(
                      icon: AppIcons.logout,
                      iconColor: NeoTokens.vividYellow,
                      title: 'Keluar dari Akun',
                      subtitle: 'Akhiri sesi aktif Anda pada perangkat ini',
                      onTap: _handleLogout,
                    ),
                    const Divider(
                      color: NeoTokens.black,
                      height: 1,
                      thickness: 1,
                    ),
                    _menuTile(
                      icon: AppIcons.deleteForever,
                      iconColor: NeoTokens.coralRed,
                      title: 'Hapus Akun & Data',
                      subtitle: 'Hapus akun autentikasi dan data permanen',
                      textColor: NeoTokens.coralRed,
                      onTap: _isDeleting ? null : _handleDeleteAccount,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricBox({
    required String label,
    required String value,
    required String unit,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: NeoTokens.paper,
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        border: Border.all(color: NeoTokens.black, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: NeoTokens.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: NeoTokens.black,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: NeoTokens.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _targetCard(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        border: Border.all(color: NeoTokens.black, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: NeoTokens.black,
            offset: Offset(1.5, 1.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: NeoTokens.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: NeoTokens.black,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: NeoTokens.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color textColor = NeoTokens.black,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
            border: Border.all(color: NeoTokens.black, width: 1.5),
          ),
          child: Icon(icon, color: NeoTokens.black, size: AppIcons.sizeControl),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: NeoTokens.textMuted),
        ),
        trailing: const Icon(
          AppIcons.chevronRight,
          color: NeoTokens.black,
          size: AppIcons.sizeToolbar,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _switchMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
            border: Border.all(color: NeoTokens.black, width: 1.5),
          ),
          child: Icon(icon, color: NeoTokens.black, size: AppIcons.sizeControl),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: NeoTokens.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: NeoTokens.textMuted),
        ),
        trailing: Switch.adaptive(
          value: value,
          activeThumbColor: NeoTokens.black,
          activeTrackColor: NeoTokens.lime,
          inactiveThumbColor: NeoTokens.white,
          inactiveTrackColor: NeoTokens.recess,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
