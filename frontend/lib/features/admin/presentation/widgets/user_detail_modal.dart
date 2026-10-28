import 'package:flutter/material.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/shared/neo/neo.dart';

class UserDetailModal extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onToggleStatus;

  const UserDetailModal({
    super.key,
    required this.user,
    required this.onToggleStatus,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> user,
    required VoidCallback onToggleStatus,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          UserDetailModal(user: user, onToggleStatus: onToggleStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String fullName = user['full_name'] as String? ?? 'Pengguna';
    final String email = user['email'] as String? ?? '-';
    final String role = user['role'] as String? ?? 'user';
    final bool isActive = user['is_active'] != false;
    final profile = user['profile'] as Map<String, dynamic>?;
    final String profession = profile?['profession'] as String? ?? 'Umum';
    final int userId = (user['id'] as num?)?.toInt() ?? 0;
    final String createdAt = user['created_at']?.toString() ?? '-';
    final String updatedAt = user['updated_at']?.toString() ?? '-';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: NeoTokens.warmBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: NeoTokens.ink, width: 3),
          left: BorderSide(color: NeoTokens.ink, width: 3),
          right: BorderSide(color: NeoTokens.ink, width: 3),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: NeoTokens.ink,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(AppIcons.badge, color: NeoTokens.ink),
                  SizedBox(width: 8),
                  Text(
                    'DETAIL PENGGUNA SISTEM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.ink,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(AppIcons.close, color: NeoTokens.ink),
                tooltip: 'Tutup',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(color: NeoTokens.ink, thickness: 2),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // Avatar & Identity Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: NeoTokens.paper,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusMedium,
                      ),
                      border: Border.all(
                        color: NeoTokens.ink,
                        width: NeoTokens.borderWidth,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: NeoTokens.ink,
                          offset: Offset(3, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: role == 'admin'
                              ? NeoTokens.lime
                              : NeoTokens.cobalt,
                          child: Icon(
                            role == 'admin'
                                ? AppIcons.adminPanelSettings
                                : AppIcons.person,
                            size: AppIcons.sizeState,
                            color: NeoTokens.ink,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: NeoTokens.ink,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: NeoTokens.inkSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Role & Profession Separation Warning
                  const Text(
                    'STATUS OTORISASI & ATRIBUT SOSIAL',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.inkSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: role == 'admin'
                                ? NeoTokens.lime
                                : NeoTokens.paper,
                            borderRadius: BorderRadius.circular(
                              NeoTokens.radiusSmall,
                            ),
                            border: Border.all(
                              color: NeoTokens.ink,
                              width: NeoTokens.borderWidthThin,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ROLE KEAMANAN',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: NeoTokens.inkSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              NeoBadge(
                                label: role == 'admin'
                                    ? 'ADMINISTRATOR'
                                    : 'USER BIASA',
                                color: role == 'admin'
                                    ? NeoBadgeColor.mint
                                    : NeoBadgeColor.yellow,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: NeoTokens.recess,
                            borderRadius: BorderRadius.circular(
                              NeoTokens.radiusSmall,
                            ),
                            border: Border.all(
                              color: NeoTokens.ink,
                              width: NeoTokens.borderWidthThin,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PROFESI SOSIAL',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: NeoTokens.inkSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profession,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: NeoTokens.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Metadata Details
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: NeoTokens.paper,
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
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildRow(
                          'Status Akun',
                          isActive
                              ? 'AKTIF (Dapat Login)'
                              : 'NONAKTIF (Diblokir)',
                        ),
                        const Divider(color: NeoTokens.ink, thickness: 1),
                        _buildRow('ID Pengguna', '$userId'),
                        const Divider(color: NeoTokens.ink, thickness: 1),
                        _buildRow('Terdaftar', createdAt),
                        const Divider(color: NeoTokens.ink, thickness: 1),
                        _buildRow('Pembaruan Terakhir', updatedAt),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Button
                  NeoButton(
                    text: isActive
                        ? 'Nonaktifkan Akun Ini'
                        : 'Aktifkan Kembali Akun Ini',
                    prefixIcon: isActive
                        ? AppIcons.block
                        : AppIcons.checkCircleOutline,
                    variant: isActive
                        ? NeoButtonVariant.danger
                        : NeoButtonVariant.primary,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onToggleStatus();
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: NeoTokens.inkSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: NeoTokens.ink,
            ),
          ),
        ],
      ),
    );
  }
}
