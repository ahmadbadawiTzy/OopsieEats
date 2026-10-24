import 'package:flutter/material.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/data/models/article.dart';
import 'package:nutriview/shared/neo/neo.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ArticleItem article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        title: const Text('Artikel Nutrisi'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: NeoTokens.ink, height: 2),
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
            // Category Badge & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (article.categoryName != null)
                  NeoBadge(
                    label: article.categoryName!.toUpperCase(),
                    color: NeoBadgeColor.mint,
                  )
                else
                  const SizedBox.shrink(),
                if (article.publishedAt != null)
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
            const SizedBox(height: 12),

            // Title
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
            const SizedBox(height: 8),

            // Author Info
            if (article.authorName != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.person_pin_rounded,
                    size: 16,
                    color: NeoTokens.inkSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ditulis oleh ${article.authorName}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: NeoTokens.inkSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Cover Image Banner
            if (article.coverImageUrl != null &&
                article.coverImageUrl!.trim().isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  border: Border.all(
                    color: NeoTokens.ink,
                    width: NeoTokens.borderWidthThin,
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
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      color: NeoTokens.recess,
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 20,
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
                        height: 180,
                        color: NeoTokens.recess,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],

            // Content Card
            NeoCard(
              padding: const EdgeInsets.all(NeoTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (article.excerpt != null &&
                      article.excerpt!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
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
                      child: Text(
                        article.excerpt!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: NeoTokens.ink,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                  Text(
                    article.contentMarkdown ?? 'Konten artikel belum tersedia.',
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: NeoTokens.ink,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
