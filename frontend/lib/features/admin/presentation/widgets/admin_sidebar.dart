import 'package:flutter/material.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/shared/neo/neo.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final String adminName;
  final String adminEmail;
  final String adminRole;
  final VoidCallback onOpenUserMode;
  final VoidCallback onLogout;
  final VoidCallback onOpenCategories;
  final VoidCallback onOpenMedia;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.adminName,
    required this.adminEmail,
    required this.adminRole,
    required this.onOpenUserMode,
    required this.onLogout,
    required this.onOpenCategories,
    required this.onOpenMedia,
  });

  void _safeCallback(BuildContext context, VoidCallback callback) {
    final scaffold = Scaffold.maybeOf(context);
    callback();
    if (scaffold?.isDrawerOpen ?? false) {
      scaffold?.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;

    return Container(
      width: NeoTokens.sidebarWidth,
      decoration: const BoxDecoration(
        color: NeoTokens.canvas,
        border: Border(
          right: BorderSide(color: NeoTokens.ink, width: NeoTokens.borderWidth),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand Header with top safe area support
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: topPadding > 0 ? topPadding + 4 : 12,
              bottom: 10,
            ),
            decoration: const BoxDecoration(
              color: NeoTokens.paper,
              border: Border(
                bottom: BorderSide(
                  color: NeoTokens.ink,
                  width: NeoTokens.borderWidth,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: NeoTokens.lime,
                        borderRadius: BorderRadius.circular(
                          NeoTokens.radiusSmall,
                        ),
                        border: Border.all(
                          color: NeoTokens.ink,
                          width: NeoTokens.borderWidthThin,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: NeoTokens.ink,
                            offset: Offset(1.5, 1.5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        AppIcons.adminPanelSettings,
                        size: AppIcons.sizeMedium,
                        color: NeoTokens.ink,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'NutriView',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.ink,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Redesigned Tactical Admin Account Card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: NeoTokens.canvas,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                    border: Border.all(
                      color: NeoTokens.ink,
                      width: NeoTokens.borderWidthThin,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: NeoTokens.ink,
                        offset: Offset(1.5, 1.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: NeoTokens.lime,
                              borderRadius: BorderRadius.circular(
                                NeoTokens.radiusSmall,
                              ),
                              border: Border.all(
                                color: NeoTokens.ink,
                                width: NeoTokens.borderWidthThin,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: NeoTokens.ink,
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              adminName.isNotEmpty
                                  ? adminName[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                color: NeoTokens.ink,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  adminName.isNotEmpty
                                      ? adminName
                                      : 'Administrator',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: NeoTokens.ink,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  adminEmail.isNotEmpty
                                      ? adminEmail
                                      : 'admin@nutriview.com',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: NeoTokens.inkSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: NeoTokens.hazard,
                              borderRadius: BorderRadius.circular(
                                NeoTokens.radiusSmall,
                              ),
                              border: Border.all(
                                color: NeoTokens.ink,
                                width: 1.0,
                              ),
                            ),
                            child: const Text(
                              'ROLE: ADMIN',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: NeoTokens.ink,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: NeoTokens.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'ONLINE',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: NeoTokens.inkSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              children: [
                _buildSectionHeader('IKHTISAR SISTEM'),
                _buildNavItem(
                  context,
                  index: 0,
                  label: 'RINGKASAN',
                  icon: AppIcons.gridView,
                ),
                const SizedBox(height: 6),
                _buildSectionHeader('DATA GIZI & PANGAN'),
                _buildNavItem(
                  context,
                  index: 1,
                  label: 'KATALOG PANGAN',
                  icon: AppIcons.restaurantMenu,
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  label: 'SIMULATOR ATWATER',
                  icon: AppIcons.balance,
                ),
                const SizedBox(height: 6),
                _buildSectionHeader('CMS & KONTEN'),
                _buildNavItem(
                  context,
                  index: 3,
                  label: 'ARTIKEL EDUKASI',
                  icon: AppIcons.article,
                ),
                _buildQuickActionItem(
                  context,
                  label: 'Kelola Kategori CMS',
                  icon: AppIcons.category,
                  onTap: onOpenCategories,
                ),
                _buildQuickActionItem(
                  context,
                  label: 'Galeri Aset Media',
                  icon: AppIcons.photoLibrary,
                  onTap: onOpenMedia,
                ),
                const SizedBox(height: 6),
                _buildSectionHeader('AKSES & AUDIT'),
                _buildNavItem(
                  context,
                  index: 4,
                  label: 'MANAJEMEN PENGGUNA',
                  icon: AppIcons.peopleAlt,
                ),
                _buildNavItem(
                  context,
                  index: 5,
                  label: 'LOG AUDIT TRAIL',
                  icon: AppIcons.history,
                ),
              ],
            ),
          ),

          // Footer with bottom safe area support
          Container(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top: 8,
              bottom: bottomPadding > 0 ? bottomPadding + 10 : 12,
            ),
            decoration: const BoxDecoration(
              color: NeoTokens.paper,
              border: Border(
                top: BorderSide(
                  color: NeoTokens.ink,
                  width: NeoTokens.borderWidth,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeoButton(
                  text: 'Mode Pengguna',
                  prefixIcon: AppIcons.arrowBack,
                  height: 38,
                  variant: NeoButtonVariant.secondary,
                  onPressed: () => _safeCallback(context, onOpenUserMode),
                ),
                const SizedBox(height: 6),
                NeoButton(
                  text: 'Keluar Portal',
                  prefixIcon: AppIcons.logout,
                  height: 38,
                  variant: NeoButtonVariant.danger,
                  onPressed: () => _safeCallback(context, onLogout),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 4, top: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: NeoTokens.inkSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => _safeCallback(context, () => onItemSelected(index)),
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? NeoTokens.lime : NeoTokens.paper,
            borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
            border: Border.all(
              color: NeoTokens.ink,
              width: isSelected
                  ? NeoTokens.borderWidth
                  : NeoTokens.borderWidthThin,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: NeoTokens.ink,
                      offset: Offset(2.5, 2.5),
                      blurRadius: 0,
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: NeoTokens.ink,
                      offset: Offset(1.5, 1.5),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Row(
            children: [
              Icon(icon, size: AppIcons.sizeMedium, color: NeoTokens.ink),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    color: NeoTokens.ink,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: NeoTokens.ink,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => _safeCallback(context, onTap),
        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: NeoTokens.canvas,
            borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
            border: Border.all(color: NeoTokens.inkSecondary, width: 1.0),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppIcons.sizeSmall,
                color: NeoTokens.inkSecondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: NeoTokens.inkSecondary,
                  ),
                ),
              ),
              const Icon(
                AppIcons.arrowForward,
                size: AppIcons.sizeSmall,
                color: NeoTokens.inkSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
