import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/data/models/article.dart';
import 'package:nutriview/shared/neo/neo_badge.dart';
import 'package:nutriview/shared/neo/neo_card.dart';

/// Overkill Neo-Brutalist Nutrition Field Notes & Articles Preview Section.
class LatestArticlesSection extends StatelessWidget {
  final List<ArticleItem> articles;
  final ValueChanged<ArticleItem> onArticleTapped;
  final VoidCallback onViewAllArticles;

  const LatestArticlesSection({
    super.key,
    required this.articles,
    required this.onArticleTapped,
    required this.onViewAllArticles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.menu_book_rounded, color: NeoTokens.ink, size: 18),
                SizedBox(width: 6),
                Text(
                  '[05] NUTRITION FIELD NOTES',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: NeoTokens.ink,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: onViewAllArticles,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: NeoTokens.lime,
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'LIHAT SEMUA',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.ink,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 11,
                      color: NeoTokens.ink,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Pengetahuan kecil, kebiasaan yang lebih baik.',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: NeoTokens.inkSecondary,
          ),
        ),
        const SizedBox(height: NeoTokens.space10),

        if (articles.isEmpty)
          NeoCard(
            backgroundColor: NeoTokens.paper,
            padding: const EdgeInsets.all(NeoTokens.space16),
            child: const Center(
              child: Text(
                'Belum ada artikel edukasi yang dipublikasikan.',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: NeoTokens.inkMuted,
                ),
              ),
            ),
          )
        else
          ...articles.take(3).map((art) {
            final hasCover =
                art.coverImageUrl != null &&
                art.coverImageUrl!.trim().isNotEmpty;

            return NeoCard(
              margin: const EdgeInsets.only(bottom: NeoTokens.space8),
              padding: const EdgeInsets.all(NeoTokens.space12),
              onTap: () => onArticleTapped(art),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cover Image with Fallback
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: NeoTokens.lilac,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusSmall,
                      ),
                      border: Border.all(
                        color: NeoTokens.ink,
                        width: NeoTokens.borderWidthThin,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: hasCover
                        ? Image.network(
                            art.coverImageUrl!.trim(),
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildFallbackBanner(),
                          )
                        : _buildFallbackBanner(),
                  ),
                  const SizedBox(width: NeoTokens.space12),

                  // Article Metadata & Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (art.categoryName != null &&
                            art.categoryName!.isNotEmpty) ...[
                          NeoBadge(
                            label: art.categoryName!.toUpperCase(),
                            color: NeoBadgeColor.mint,
                            fontSize: 9,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                          ),
                          const SizedBox(height: 3),
                        ],
                        Text(
                          art.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: NeoTokens.ink,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (art.excerpt != null && art.excerpt!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            art.excerpt!,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: NeoTokens.inkSecondary,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: NeoTokens.inkSecondary,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      color: NeoTokens.recess,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NV.EDUKASI',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                color: NeoTokens.ink,
              ),
            ),
            Icon(Icons.menu_book_rounded, color: NeoTokens.ink, size: 16),
          ],
        ),
      ),
    );
  }
}
