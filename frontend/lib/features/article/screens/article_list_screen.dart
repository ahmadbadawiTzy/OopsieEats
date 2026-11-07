import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/data/models/article.dart';
import 'package:nutriview/data/repositories/article_repository.dart';
import 'package:nutriview/shared/neo/neo.dart';

/// Overkill Neo-Brutalism Editorial Nutrition Journal for NutriView Users.
/// Designed according to Section 15 specifications:
/// - Bold, authentic neo-brutalism with thick outlines and crisp offset shadows
/// - Editorial typography and composition with distinct visual hierarchy
/// - Featured Hero Article for primary visual anchor + magazine-style list items
/// - Customer-oriented copywriting in natural Indonesian (zero AI slop or tech jargon)
/// - High scroll performance, strict responsiveness, and accessibility compliance
class ArticleListScreen extends StatefulWidget {
  final bool isTab;

  const ArticleListScreen({super.key, this.isTab = false});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;
  List<ArticleItem> _articles = [];
  List<CategoryItem> _categories = [];
  int? _selectedCategoryId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<ArticleRepository>();
      final catsFuture = repo.getCategories();
      final artsFuture = repo.getArticles(
        categoryId: _selectedCategoryId,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        limit: 50,
      );

      final results = await Future.wait([catsFuture, artsFuture]);
      if (mounted) {
        setState(() {
          _categories = results[0] as List<CategoryItem>;
          final articleData = results[1] as Map<String, dynamic>;
          _articles = articleData['items'] as List<ArticleItem>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat artikel: $e';
        });
      }
    }
  }

  Future<void> _filterArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<ArticleRepository>();
      final articleData = await repo.getArticles(
        categoryId: _selectedCategoryId,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        limit: 50,
      );

      if (mounted) {
        setState(() {
          _articles = articleData['items'] as List<ArticleItem>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal memuat artikel: $e';
        });
      }
    }
  }

  void _onCategorySelected(int? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _filterArticles();
  }

  void _onSearchSubmitted(String value) {
    final query = value.trim();
    if (query == _searchQuery) return;
    setState(() {
      _searchQuery = query;
    });
    _filterArticles();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _filterArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isTab,
        elevation: 0,
        backgroundColor: NeoTokens.warmBackground,
        titleSpacing: NeoTokens.space16,
        leading: widget.isTab ? null : const NeoBackButton(),
        title: const Text(
          'Artikel Nutrisi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: NeoTokens.ink,
            letterSpacing: -0.4,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.5),
          child: Container(color: NeoTokens.ink, height: 1.5),
        ),
      ),
      body: RefreshIndicator(
        color: NeoTokens.ink,
        backgroundColor: NeoTokens.lime,
        onRefresh: _loadData,
        child: Column(
          children: [
            // Editorial Header & Discovery Panel (Search & Category Filters)
            _buildDiscoveryHeader(),

            // Article Content Area (Featured + Editorial List)
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryHeader() {
    return Container(
      color: NeoTokens.warmBackground,
      padding: const EdgeInsets.fromLTRB(
        NeoTokens.space16,
        NeoTokens.space14,
        NeoTokens.space16,
        NeoTokens.space12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer-Centric Subtitle
          const Text(
            'Panduan makan sehat & gizi seimbang untuk keseharianmu.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: NeoTokens.inkSecondary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: NeoTokens.space12),

          // Comfortable Neo-Brutalist Search Field (54dp height)
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: NeoTokens.paper,
              borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
              border: Border.all(
                color: NeoTokens.ink,
                width: NeoTokens.borderWidth,
              ),
              boxShadow: NeoTokens.neoBoxShadowSmall(),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 14, right: 10),
                  child: Icon(
                    AppIcons.search,
                    size: AppIcons.sizeToolbar,
                    color: NeoTokens.ink,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _onSearchSubmitted,
                    onChanged: (val) {
                      if (val.isEmpty && _searchQuery.isNotEmpty) {
                        _clearSearch();
                      } else {
                        setState(() {});
                      }
                    },
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: NeoTokens.ink,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Cari artikel nutrisi...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: NeoTokens.inkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: IconButton(
                      icon: const Icon(
                        AppIcons.close,
                        size: AppIcons.sizeControl,
                        color: NeoTokens.ink,
                      ),
                      onPressed: _clearSearch,
                      tooltip: 'Hapus pencarian',
                      splashRadius: 20,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: NeoTokens.space12),

          // Horizontal Editorial Category Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildCategoryPill(
                  label: 'Semua',
                  isSelected: _selectedCategoryId == null,
                  onTap: () => _onCategorySelected(null),
                ),
                ..._categories.map((cat) {
                  return _buildCategoryPill(
                    label: cat.name,
                    isSelected: _selectedCategoryId == cat.id,
                    onTap: () => _onCategorySelected(cat.id),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? NeoTokens.lime : NeoTokens.paper,
            borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
            border: Border.all(
              color: NeoTokens.ink,
              width: isSelected ? NeoTokens.borderWidth : NeoTokens.borderWidthThin,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: NeoTokens.ink,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: NeoTokens.ink,
                      offset: Offset(1, 1),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: NeoTokens.ink,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(NeoTokens.space16),
        itemCount: 3,
        itemBuilder: (_, __) => _buildSkeletonCard(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(NeoTokens.space24),
          child: NeoCard(
            backgroundColor: NeoTokens.paper,
            padding: const EdgeInsets.all(NeoTokens.space20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  AppIcons.error,
                  size: AppIcons.sizeFeature,
                  color: NeoTokens.alert,
                ),
                const SizedBox(height: NeoTokens.space12),
                const Text(
                  'Artikel Belum Dapat Dimuat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: NeoTokens.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: NeoTokens.inkSecondary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: NeoTokens.space16),
                NeoButton(
                  text: 'Coba Lagi',
                  variant: NeoButtonVariant.primary,
                  onPressed: _loadData,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_articles.isEmpty) {
      final isSearching = _searchQuery.isNotEmpty;
      final isCategoryFiltered = _selectedCategoryId != null;

      String title;
      String description;
      String buttonText;
      VoidCallback onAction;

      if (isSearching) {
        title = 'Artikel Tidak Ditemukan';
        description =
            'Tidak ada artikel yang cocok dengan kata kunci "$_searchQuery". Coba gunakan kata kunci lain atau tampilkan semua artikel.';
        buttonText = 'Tampilkan Semua Artikel';
        onAction = () {
          _searchController.clear();
          setState(() {
            _searchQuery = '';
          });
          _filterArticles();
        };
      } else if (isCategoryFiltered) {
        title = 'Belum Ada Artikel';
        description =
            'Belum ada artikel pada kategori ini. Silakan pilih kategori lain atau tampilkan semua.';
        buttonText = 'Tampilkan Semua Kategori';
        onAction = () => _onCategorySelected(null);
      } else {
        title = 'Belum Ada Artikel';
        description =
            'Artikel seputar gizi dan panduan nutrisi sehat akan segera hadir.';
        buttonText = 'Muat Ulang';
        onAction = _loadData;
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(NeoTokens.space24),
          child: NeoCard(
            backgroundColor: NeoTokens.paper,
            padding: const EdgeInsets.all(NeoTokens.space24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: NeoTokens.recess,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                    border: Border.all(
                      color: NeoTokens.ink,
                      width: NeoTokens.borderWidthThin,
                    ),
                    boxShadow: NeoTokens.neoBoxShadowSmall(),
                  ),
                  child: Icon(
                    isSearching ? AppIcons.searchOff : AppIcons.article,
                    size: AppIcons.sizeState,
                    color: NeoTokens.ink,
                  ),
                ),
                const SizedBox(height: NeoTokens.space16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: NeoTokens.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: NeoTokens.inkSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: NeoTokens.space16),
                NeoButton(
                  text: buttonText,
                  variant: NeoButtonVariant.primary,
                  onPressed: onAction,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Editorial Hierarchy:
    // If not searching, article[0] is displayed as the prominent Featured Hero Card,
    // and subsequent articles are displayed in the editorial magazine list layout.
    final hasFeatured = _searchQuery.isEmpty && _articles.isNotEmpty;
    final featuredArticle = hasFeatured ? _articles.first : null;
    final remainingArticles = hasFeatured ? _articles.skip(1).toList() : _articles;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        NeoTokens.space16,
        NeoTokens.space4,
        NeoTokens.space16,
        100,
      ),
      children: [
        // 1. Featured Article Anchor
        if (featuredArticle != null) ...[
          _buildFeaturedCard(featuredArticle),
          if (remainingArticles.isNotEmpty) ...[
            const SizedBox(height: NeoTokens.space14),
            _buildSectionDivider('BACAAN LAINNYA'),
            const SizedBox(height: NeoTokens.space10),
          ],
        ],

        // 2. Editorial Magazine List
        ...remainingArticles.map((art) => _buildEditorialListItem(art)),
      ],
    );
  }

  Widget _buildSectionDivider(String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: NeoTokens.hud,
            borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: NeoTokens.paper,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1.5,
            color: NeoTokens.ink,
          ),
        ),
      ],
    );
  }

  /// Featured Hero Article Card with prominent scale, bold editorial typography,
  /// and high visual contrast.
  Widget _buildFeaturedCard(ArticleItem article) {
    final formattedDate = _formatPublishedDate(article.publishedAt);

    return RepaintBoundary(
      child: NeoCard(
        margin: const EdgeInsets.only(bottom: NeoTokens.space8),
        padding: const EdgeInsets.all(NeoTokens.space14),
        borderWidth: NeoTokens.borderWidth,
        shadowOffset: NeoTokens.shadowOffset,
        onTap: () => _navigateToDetail(article),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Proportional Hero Cover Image
            _buildCoverImage(article.coverImageUrl, height: 160),

            const SizedBox(height: NeoTokens.space12),

            // Category & Published Date
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                NeoBadge(
                  label: (article.categoryName != null && article.categoryName!.isNotEmpty)
                      ? article.categoryName!
                      : 'Nutrisi',
                  color: NeoBadgeColor.mint,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                ),
                if (formattedDate.isNotEmpty)
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: NeoTokens.inkSecondary,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: NeoTokens.space10),

            // Prominent Display Title
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: NeoTokens.ink,
                letterSpacing: -0.4,
                height: 1.25,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Editorial Excerpt
            if (article.excerpt != null && article.excerpt!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                article.excerpt!.trim(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: NeoTokens.inkSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: NeoTokens.space14),

            // Card Footer: Author + Visual Tap Indicator ("Baca Artikel")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (article.authorName != null && article.authorName!.isNotEmpty)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          AppIcons.personOutline,
                          size: AppIcons.sizeMedium,
                          color: NeoTokens.inkSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            article.authorName!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: NeoTokens.inkSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),

                // Action Pill
                _buildReadButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Compact Editorial Magazine List Item for secondary and subsequent articles.
  /// Asymmetrical split layout with thumbnail on the left and typography on the right.
  Widget _buildEditorialListItem(ArticleItem article) {
    final formattedDate = _formatPublishedDate(article.publishedAt);
    final hasCover = article.coverImageUrl != null &&
        article.coverImageUrl!.trim().startsWith(RegExp(r'^https?:\/\/'));

    return RepaintBoundary(
      child: NeoCard(
        margin: const EdgeInsets.only(bottom: NeoTokens.space12),
        padding: const EdgeInsets.all(NeoTokens.space12),
        shadowOffset: NeoTokens.shadowOffsetSmall,
        borderWidth: NeoTokens.borderWidthThin,
        onTap: () => _navigateToDetail(article),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact Editorial Thumbnail (80x80)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: NeoTokens.recess,
                    borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                    border: Border.all(
                      color: NeoTokens.ink,
                      width: NeoTokens.borderWidthThin,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasCover
                      ? Image.network(
                          article.coverImageUrl!.trim(),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildCompactFallback(),
                        )
                      : _buildCompactFallback(),
                ),
                const SizedBox(width: NeoTokens.space12),

                // Content Block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge & Date Row
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          NeoBadge(
                            label: (article.categoryName != null &&
                                    article.categoryName!.isNotEmpty)
                                ? article.categoryName!
                                : 'Nutrisi',
                            color: NeoBadgeColor.mint,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                          ),
                          if (formattedDate.isNotEmpty)
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: NeoTokens.inkSecondary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Article Title
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.ink,
                          letterSpacing: -0.2,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Excerpt
                      if (article.excerpt != null &&
                          article.excerpt!.trim().isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          article.excerpt!.trim(),
                          style: const TextStyle(
                            fontSize: 12,
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
              ],
            ),

            const SizedBox(height: 10),

            // Bottom Sub-Row: Author & Read indicator
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                if (article.authorName != null && article.authorName!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        AppIcons.personOutline,
                        size: AppIcons.sizeSmall,
                        color: NeoTokens.inkSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.authorName!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: NeoTokens.inkSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  )
                else
                  const SizedBox.shrink(),
                _buildReadButton(isCompact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadButton({bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 4 : 5,
      ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Baca Artikel',
            style: TextStyle(
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.w900,
              color: NeoTokens.ink,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            AppIcons.arrowForward,
            size: AppIcons.sizeSmall,
            color: NeoTokens.ink,
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(ArticleItem article) {
    Navigator.pushNamed(
      context,
      AppRoutes.articleDetail,
      arguments: article,
    );
  }

  String _formatPublishedDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('d MMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return rawDate.split('T').first;
    }
  }

  Widget _buildCoverImage(String? url, {double height = 150}) {
    final validUrl =
        url != null && url.trim().startsWith(RegExp(r'^https?:\/\/'));

    if (!validUrl) {
      return _buildFallbackBanner();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
        border: Border.all(
          color: NeoTokens.ink,
          width: NeoTokens.borderWidthThin,
        ),
        boxShadow: const [
          BoxShadow(color: NeoTokens.ink, offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium - 1),
        child: Image.network(
          url.trim(),
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              height: height,
              color: NeoTokens.recess,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(NeoTokens.ink),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackBanner();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: NeoTokens.recess,
        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
        border: Border.all(
          color: NeoTokens.ink,
          width: NeoTokens.borderWidthThin,
        ),
        boxShadow: const [
          BoxShadow(color: NeoTokens.ink, offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              AppIcons.menuBook,
              size: AppIcons.sizeEmpty,
              color: NeoTokens.ink,
            ),
            SizedBox(height: 8),
            Text(
              'Panduan Gizi & Nutrisi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: NeoTokens.inkSecondary,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactFallback() {
    return const Center(
      child: Icon(
        AppIcons.menuBook,
        size: AppIcons.sizeControl,
        color: NeoTokens.inkSecondary,
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return NeoCard(
      margin: const EdgeInsets.only(bottom: NeoTokens.space12),
      padding: const EdgeInsets.all(NeoTokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: NeoTokens.recess,
              borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
              border: Border.all(
                color: NeoTokens.ink,
                width: NeoTokens.borderWidthThin,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(width: 80, height: 16, color: NeoTokens.recess),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 20,
            color: NeoTokens.recess,
          ),
          const SizedBox(height: 6),
          Container(width: 180, height: 14, color: NeoTokens.recess),
        ],
      ),
    );
  }
}
