import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/features/auth/providers/auth_provider.dart';
import 'package:nutriview/features/profile/providers/profile_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';
import 'package:nutriview/shared/widgets/loading_indicator.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProfileProvider>().loadProfile();
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  Future<void> _openAvatarCatalog(ProfileProvider profileProvider) async {
    final currentAvatarId =
        profileProvider.user?.avatarPreset ?? AvatarCatalog.defaultAvatarId;

    final selectedId = await AvatarSelectionModal.show(
      context,
      currentAvatarId: currentAvatarId,
    );

    if (selectedId != null && selectedId != currentAvatarId && mounted) {
      final success = await profileProvider.updateAvatar(avatarPreset: selectedId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: NeoTokens.black,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: NeoTokens.mintGreen, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Avatar berhasil diubah ke ${AvatarCatalog.getById(selectedId).name}!',
                    style: const TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await NeoDialog.show(
      context,
      title: 'Keluar dari Akun?',
      message:
          'Apakah Anda yakin ingin keluar dari akun NutriView? Anda perlu masuk kembali untuk mengakses data gizi Anda.',
      confirmText: 'Ya, Logout',
      cancelText: 'Batal',
      confirmColor: NeoTokens.alert,
      icon: Icons.logout_rounded,
    );

    if (confirmed == true && mounted) {
      final auth = context.read<AuthProvider>();
      final nav = Navigator.of(context);
      await auth.logout();
      if (!mounted) return;
      nav.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await NeoDialog.show(
      context,
      title: 'Hapus Akun & Data?',
      message:
          'PERINGATAN: Tindakan ini bersifat permanen. Seluruh akun, profil, target gizi, dan riwayat makanan Anda akan dihapus secara permanen dari server.',
      confirmText: 'Hapus Akun',
      cancelText: 'Batal',
      confirmColor: NeoTokens.alert,
      icon: Icons.delete_forever_rounded,
    );

    if (confirmed == true && mounted) {
      final auth = context.read<AuthProvider>();
      final nav = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      final success = await auth.deleteAccount();
      if (!mounted) return;

      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Akun Anda telah berhasil dihapus.'),
            backgroundColor: NeoTokens.black,
          ),
        );
        nav.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      } else if (auth.errorMessage != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage!),
            backgroundColor: NeoTokens.alert,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

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
            icon: const Icon(Icons.info_outline_rounded, color: NeoTokens.ink),
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
                                  border: Border.all(color: NeoTokens.black, width: 2),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: NeoTokens.black,
                                      offset: Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 18,
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
                        fontSize: 12.5,
                        color: NeoTokens.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Character Name Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: character.backgroundColor,
                        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
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
                    const SizedBox(height: NeoTokens.space16),

                    // "Ganti Avatar" Button
                    SizedBox(
                      width: double.infinity,
                      child: NeoButton(
                        text: 'Pilih Karakter Avatar',
                        variant: NeoButtonVariant.secondary,
                        prefixIcon: Icons.theater_comedy_rounded,
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
                      final updated = await Navigator.pushNamed(context, AppRoutes.biodata);
                      if (updated == true && mounted) {
                        profileProvider.loadProfile();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: NeoTokens.vividYellow,
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
                      child: Row(
                        children: [
                          Icon(
                            profile != null ? Icons.edit_note_rounded : Icons.add_circle_outline_rounded,
                            size: 16,
                            color: NeoTokens.black,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile != null ? 'Kelola Biodata' : 'Isi Biodata',
                            style: const TextStyle(
                              fontSize: 11.5,
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
                          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                          border: Border.all(color: NeoTokens.black, width: 2),
                        ),
                        child: const Icon(Icons.fitness_center_rounded, color: NeoTokens.black, size: 28),
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
                        style: TextStyle(fontSize: 12, color: NeoTokens.textMuted, height: 1.35),
                      ),
                      const SizedBox(height: NeoTokens.space16),
                      NeoButton(
                        text: 'Lengkapi Biodata Sekarang',
                        variant: NeoButtonVariant.primary,
                        prefixIcon: Icons.add_rounded,
                        onPressed: () async {
                          final updated = await Navigator.pushNamed(context, AppRoutes.biodata);
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: NeoTokens.paper,
                          borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                          border: Border.all(color: NeoTokens.black, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded, size: 16, color: NeoTokens.black),
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
                                Icon(Icons.track_changes_rounded, size: 18, color: NeoTokens.black),
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
                              fontSize: 9.5,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _targetCard('Kalori', '${target.caloriesKcal}', 'kkal', NeoTokens.vividYellow)),
                            const SizedBox(width: 8),
                            Expanded(child: _targetCard('Protein', '${target.proteinG}', 'g', NeoTokens.skyBlue)),
                            const SizedBox(width: 8),
                            Expanded(child: _targetCard('Karbo', '${target.carbsG}', 'g', NeoTokens.orangeCarb)),
                            const SizedBox(width: 8),
                            Expanded(child: _targetCard('Lemak', '${target.fatG}', 'g', NeoTokens.lavender)),
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
                    _menuTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: NeoTokens.skyBlue,
                      title: 'Tentang NutriView & Pembuat',
                      subtitle: 'Profil Ahmad Badawi, tujuan & versi aplikasi',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.about),
                    ),
                    const Divider(color: NeoTokens.black, height: 1, thickness: 1),
                    _menuTile(
                      icon: Icons.logout_rounded,
                      iconColor: NeoTokens.vividYellow,
                      title: 'Keluar dari Akun',
                      subtitle: 'Akhiri sesi aktif Anda pada perangkat ini',
                      onTap: _handleLogout,
                    ),
                    const Divider(color: NeoTokens.black, height: 1, thickness: 1),
                    _menuTile(
                      icon: Icons.delete_forever_rounded,
                      iconColor: NeoTokens.coralRed,
                      title: 'Hapus Akun & Data',
                      subtitle: 'Hapus akun autentikasi dan data permanen',
                      textColor: NeoTokens.coralRed,
                      onTap: _handleDeleteAccount,
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
              fontSize: 8.5,
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
    required VoidCallback onTap,
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
          child: Icon(icon, color: NeoTokens.black, size: 20),
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
          style: const TextStyle(fontSize: 11.5, color: NeoTokens.textMuted),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: NeoTokens.black,
          size: 22,
        ),
        onTap: onTap,
      ),
    );
  }
}
