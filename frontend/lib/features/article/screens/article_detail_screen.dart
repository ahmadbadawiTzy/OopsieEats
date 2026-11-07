import 'package:flutter/material.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/data/models/article.dart';
import 'package:nutriview/shared/neo/neo.dart';

/// Overkill Neo-Brutalism Editorial Article Detail Reader for NutriView Users.
/// Prioritizes clear reading experience, strong typography hierarchy,
/// distinct editorial standfirst for excerpt, and verified nutritional sources.
class ArticleDetailScreen extends StatelessWidget {
  final ArticleItem article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        leading: NeoBackButton.leading(context),
        title: const Text('Artikel Nutrisi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: NeoTokens.ink, height: 1.5),
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
            // Category Badge & Published Date Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (article.categoryName != null && article.categoryName!.isNotEmpty)
                  NeoBadge(
                    label: article.categoryName!.toUpperCase(),
                    color: NeoBadgeColor.mint,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                  )
                else
                  const NeoBadge(
                    label: 'NUTRISI',
                    color: NeoBadgeColor.mint,
                    fontSize: 11,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  ),
                if (article.publishedAt != null && article.publishedAt!.isNotEmpty)
                  Text(
                    article.publishedAt!.split('T').first,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: NeoTokens.inkSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: NeoTokens.space12),

            // Editorial Headline Title
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: NeoTokens.ink,
                letterSpacing: -0.5,
                height: 1.25,
              ),
            ),
            const SizedBox(height: NeoTokens.space10),

            // Author Attribution
            if (article.authorName != null && article.authorName!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(
                    AppIcons.personPin,
                    size: AppIcons.sizeMedium,
                    color: NeoTokens.inkSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ditulis oleh ${article.authorName}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: NeoTokens.inkSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: NeoTokens.space16),
            ],

            // Cover Image Banner
            if (article.coverImageUrl != null &&
                article.coverImageUrl!.trim().isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: NeoTokens.space16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    NeoTokens.radiusMedium - 1,
                  ),
                  child: Image.network(
                    article.coverImageUrl!.trim(),
                    height: 190,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 90,
                      color: NeoTokens.recess,
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.imageNotSupported,
                              size: AppIcons.sizeControl,
                              color: NeoTokens.inkSecondary,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Gambar sampul tidak dapat dimuat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: NeoTokens.inkSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        height: 190,
                        color: NeoTokens.recess,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(NeoTokens.ink),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            // Editorial Content Card
            NeoCard(
              padding: const EdgeInsets.all(NeoTokens.space16),
              borderWidth: NeoTokens.borderWidth,
              shadowOffset: NeoTokens.shadowOffsetMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Standfirst / Editorial Pull-Quote Excerpt
                  if (article.excerpt != null &&
                      article.excerpt!.trim().isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(NeoTokens.space12),
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
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 38,
                            decoration: BoxDecoration(
                              color: NeoTokens.lime,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              article.excerpt!.trim(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: NeoTokens.ink,
                                height: 1.45,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space16),
                  ],

                  // Body Content with generous line height and contrast
                  SelectableText(
                    article.contentMarkdown ?? 'Konten artikel belum tersedia.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: NeoTokens.ink,
                      height: 1.65,
                      letterSpacing: -0.1,
                    ),
                  ),

                  const SizedBox(height: NeoTokens.space20),

                  // Editorial Disclaimer / Verified Guideline Source
                  Container(
                    padding: const EdgeInsets.all(NeoTokens.space10),
                    decoration: BoxDecoration(
                      color: NeoTokens.warmBackground,
                      borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                      border: Border.all(
                        color: NeoTokens.ink,
                        width: NeoTokens.borderWidthThin,
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          AppIcons.factCheck,
                          size: AppIcons.sizeSmall,
                          color: NeoTokens.inkSecondary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Informasi edukasi ini disajikan untuk panduan nutrisi harian dan tidak menggantikan rekomendasi klinis dari tenaga medis profesional.',
                            style: TextStyle(
                              fontSize: 11,
                              color: NeoTokens.inkSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NeoTokens.space32),
          ],
        ),
      ),
    );
  }
}
