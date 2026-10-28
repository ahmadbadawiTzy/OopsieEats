import 'package:flutter/material.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/shared/neo/neo.dart';

class ArticlePreviewModal extends StatelessWidget {
  final Map<String, dynamic> article;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const ArticlePreviewModal({
    super.key,
    required this.article,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<String, dynamic> article,
    required VoidCallback onEdit,
    required VoidCallback onToggleStatus,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ArticlePreviewModal(
        article: article,
        onEdit: onEdit,
        onToggleStatus: onToggleStatus,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPublished = article['status'] == 'published';
    final String title = article['title'] as String? ?? 'Tanpa Judul';
    final String summary = article['summary'] as String? ?? '';
    final String content = article['content'] as String? ?? '';
    final String author =
        article['author_name'] as String? ?? 'Tim Gizi NutriView';
    final String category =
        article['category_name'] as String? ?? 'Gizi & Nutrisi';
    final int readTime = (article['read_time_minutes'] as num?)?.toInt() ?? 3;

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
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: NeoTokens.ink,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const NeoBadge(
                    label: 'PREVIEW CMS',
                    color: NeoBadgeColor.mint,
                  ),
                  const SizedBox(width: 8),
                  NeoBadge(
                    label: isPublished ? 'TERBIT' : 'DRAF',
                    color: isPublished
                        ? NeoBadgeColor.mint
                        : NeoBadgeColor.coral,
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

                  // Category & Read Time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: NeoTokens.cobalt.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(
                            NeoTokens.radiusSmall,
                          ),
                          border: Border.all(
                            color: NeoTokens.ink,
                            width: NeoTokens.borderWidthThin,
                          ),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: NeoTokens.cobalt,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '⏱ $readTime menit baca',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: NeoTokens.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: NeoTokens.ink,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author & Date
                  Text(
                    'Ditulis oleh $author • ${article['created_at'] != null ? article['created_at'].toString().split('T').first : 'Hari ini'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: NeoTokens.inkSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Summary Box
                  if (summary.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
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
                      child: Text(
                        summary,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: NeoTokens.ink,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Content Body
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: NeoTokens.ink,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: NeoButton(
                          text: 'Edit Artikel',
                          prefixIcon: AppIcons.edit,
                          variant: NeoButtonVariant.primary,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onEdit();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeoButton(
                          text: isPublished ? 'Tarik Draf' : 'Terbitkan',
                          prefixIcon: isPublished
                              ? AppIcons.visibilityOff
                              : AppIcons.send,
                          variant: NeoButtonVariant.secondary,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onToggleStatus();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  NeoButton(
                    text: 'Hapus Artikel',
                    prefixIcon: AppIcons.deleteForever,
                    variant: NeoButtonVariant.danger,
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDelete();
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
}
