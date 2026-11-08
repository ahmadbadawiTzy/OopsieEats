import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oopsieeats/core/config/creator_config.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/shared/neo/neo.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/features/splash/widgets/neo_splash_badge.dart';

/// Dedicated "Tentang Aplikasi" screen showcasing NutriView consumer identity
/// and the authentic creator profile for Ahmad Badawi.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _copyLink(BuildContext context, String title, String url) {
    Clipboard.setData(ClipboardData(text: url));
    NeoSnackBars.success(
      context,
      'Tautan $title berhasil disalin ke papan klip!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        leading: NeoBackButton.leading(context),
        title: const Text('Tentang OopsieEats'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: NeoTokens.black, height: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: NeoTokens.space16,
          vertical: NeoTokens.space16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================================================================
            // SECTION 1: OOPSIEEATS APP IDENTITY
            // ================================================================
            NeoCard(
              backgroundColor: NeoTokens.white,
              padding: const EdgeInsets.all(NeoTokens.space20),
              child: Column(
                children: [
                  const OopsieEatsLogoMark(size: 64),
                  const SizedBox(height: NeoTokens.space12),
                  const Text(
                    CreatorConfig.appName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Versi ${CreatorConfig.appVersion}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: NeoTokens.textMuted,
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space12),
                  Text(
                    CreatorConfig.appDescription,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: NeoTokens.textDark,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NeoTokens.space16),

            // ================================================================
            // SECTION 2: DEVELOPER PROFILE (AHMAD BADAWI)
            // ================================================================
            const NeoSectionHeader(
              title: 'Profil Pengembang',
              accentColor: NeoTokens.vividYellow,
            ),
            const SizedBox(height: NeoTokens.space8),

            NeoCard(
              backgroundColor: NeoTokens.paper,
              padding: const EdgeInsets.all(NeoTokens.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Developer Role Badge & Headline
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Creator Photo with Neo-Brutalist Frame & Fallback
                      Container(
                        width: 84,
                        height: 112,
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
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          CreatorConfig.creatorPhotoAsset,
                          width: 84,
                          height: 112,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          cacheWidth: 252,
                          cacheHeight: 336,
                          semanticLabel: 'Foto Pengembang Ahmad Badawi',
                          errorBuilder: (context, error, stackTrace) {
                            return _buildCreatorPlaceholder();
                          },
                        ),
                      ),
                      const SizedBox(width: NeoTokens.space16),

                      // Name, Role, Profession & Domain Chips
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: NeoTokens.vividYellow,
                                borderRadius: BorderRadius.circular(
                                  NeoTokens.radiusSmall,
                                ),
                                border: Border.all(
                                  color: NeoTokens.black,
                                  width: 1.5,
                                ),
                              ),
                              child: const Text(
                                'DIKEMBANGKAN OLEH',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: NeoTokens.black,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              CreatorConfig.creatorName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: NeoTokens.black,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              CreatorConfig.creatorRole,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: NeoTokens.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              CreatorConfig.creatorProfession,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: NeoTokens.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 5,
                              runSpacing: 4,
                              children: [
                                _buildDomainChip('Web', NeoTokens.skyBlue),
                                _buildDomainChip('AI', NeoTokens.vividYellow),
                                _buildDomainChip('Mobile', NeoTokens.mintGreen),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NeoTokens.space16),

                  // Bio Quotation Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: NeoTokens.white,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusSmall,
                      ),
                      border: Border.all(
                        color: NeoTokens.black,
                        width: NeoTokens.borderWidthThin,
                      ),
                    ),
                    child: const Text(
                      CreatorConfig.creatorBio,
                      style: TextStyle(
                        fontSize: 13,
                        color: NeoTokens.textDark,
                        height: 1.45,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space16),

                  // Verified Professional Links
                  const Text(
                    'TAUTAN RESMI PENGEMBANG:',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: NeoTokens.space8),

                  _buildLinkButton(
                    context,
                    label: 'GitHub',
                    value: 'github.com/ahmadbadawiTzy',
                    fullUrl: CreatorConfig.githubUrl,
                    icon: AppIcons.code,
                    color: NeoTokens.white,
                  ),
                  const SizedBox(height: 8),
                  _buildLinkButton(
                    context,
                    label: 'LinkedIn',
                    value: 'Ahmad Badawi',
                    fullUrl: CreatorConfig.linkedinUrl,
                    icon: AppIcons.businessCenter,
                    color: NeoTokens.white,
                  ),
                  const SizedBox(height: 8),
                  _buildLinkButton(
                    context,
                    label: 'Instagram',
                    value: CreatorConfig.instagramHandle,
                    fullUrl: CreatorConfig.instagramUrl,
                    icon: AppIcons.cameraAlt,
                    color: NeoTokens.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: NeoTokens.space20),

            // ================================================================
            // SECTION 3: KEY VALUE PILLARS
            // ================================================================
            const NeoSectionHeader(
              title: 'Nilai Utama Aplikasi',
              accentColor: NeoTokens.mintGreen,
            ),
            const SizedBox(height: NeoTokens.space8),

            _buildPillarTile(
              icon: AppIcons.cameraAlt,
              iconColor: NeoTokens.vividYellow,
              title: 'Pemindai Makanan Praktis',
              subtitle: 'Kenali jenis makanan dari foto kamera atau galeri untuk pencatatan gizi harian yang cepat.',
            ),
            _buildPillarTile(
              icon: AppIcons.factCheck,
              iconColor: NeoTokens.mintGreen,
              title: 'Data Gizi Terverifikasi',
              subtitle: 'Estimasi nilai kalori dan makronutrien merujuk pada Tabel Komposisi Pangan Indonesia (TKPI).',
            ),
            _buildPillarTile(
              icon: AppIcons.calculate,
              iconColor: NeoTokens.skyBlue,
              title: 'Kebutuhan Kalori Personal',
              subtitle: 'Target dihitung akurat berdasarkan umur dari tanggal lahir, tinggi badan, berat badan, dan aktivitas.',
            ),
            _buildPillarTile(
              icon: AppIcons.menuBook,
              iconColor: NeoTokens.lavender,
              title: 'Artikel & Panduan Gizi Seimbang',
              subtitle: 'Wawasan nutrisi terpercaya yang mudah dipahami untuk mendukung pola hidup sehat.',
            ),
            const SizedBox(height: NeoTokens.space20),

            // ================================================================
            // SECTION 4: PRIVACY & DATA SAFETY COMPLIANCE (GOOGLE PLAY)
            // ================================================================
            const NeoSectionHeader(
              title: 'Privasi & Keamanan Data',
              accentColor: NeoTokens.skyBlue,
            ),
            const SizedBox(height: NeoTokens.space8),

            NeoCard(
              backgroundColor: NeoTokens.white,
              padding: const EdgeInsets.all(NeoTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPillarTile(
                    icon: AppIcons.shield,
                    iconColor: NeoTokens.mintGreen,
                    title: 'Pemrosesan AI On-Device',
                    subtitle: 'Foto makanan diproses lokal di perangkat dengan model TFLite tanpa pernah diunggah ke server cloud eksternal.',
                  ),
                  _buildPillarTile(
                    icon: AppIcons.lock,
                    iconColor: NeoTokens.skyBlue,
                    title: 'Isolasi Akun Multi-Tenant',
                    subtitle: 'Data profil dan riwayat makanan terenkripsi dan hanya dapat diakses oleh akun pemilik yang terautentikasi.',
                  ),
                  _buildPillarTile(
                    icon: AppIcons.deleteForever,
                    iconColor: NeoTokens.coralRed,
                    title: 'Kendali & Penghapusan Akun',
                    subtitle: 'Pengguna memiliki hak penuh menghapus data dan akun secara permanen langsung dari menu Profil.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: NeoTokens.space24),

            // Footer note
            Center(
              child: Text(
                '© 2026 ${CreatorConfig.creatorName} · OopsieEats',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NeoTokens.textMuted,
                ),
              ),
            ),
            const SizedBox(height: NeoTokens.space16),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorPlaceholder() {
    return Container(
      color: NeoTokens.vividYellow,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            AppIcons.person,
            size: AppIcons.sizeFeature,
            color: NeoTokens.black,
          ),
          SizedBox(height: 2),
          Text(
            'AB',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: NeoTokens.black,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDomainChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        border: Border.all(color: NeoTokens.black, width: 1.5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: NeoTokens.black,
        ),
      ),
    );
  }

  Widget _buildPillarTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoCard(
        backgroundColor: NeoTokens.white,
        padding: const EdgeInsets.all(12),
        shadowOffset: NeoTokens.shadowOffsetSmall,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                border: Border.all(color: NeoTokens.black, width: 1.5),
              ),
              child: Icon(
                icon,
                color: NeoTokens.black,
                size: AppIcons.sizeControl,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: NeoTokens.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: NeoTokens.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton(
    BuildContext context, {
    required String label,
    required String value,
    required String fullUrl,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _copyLink(context, label, fullUrl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
          border: Border.all(color: NeoTokens.black, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: NeoTokens.black,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: AppIcons.sizeLarge, color: NeoTokens.black),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: NeoTokens.black,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NeoTokens.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              AppIcons.copy,
              size: AppIcons.sizeMedium,
              color: NeoTokens.black,
            ),
          ],
        ),
      ),
    );
  }
}
