class ArticleItem {
  final int id;
  final String title;
  final String slug;
  final String? excerpt;
  final String? coverImageUrl;
  final int? categoryId;
  final String? categoryName;
  final String? authorName;
  final String status;
  final String? contentMarkdown;
  final String? publishedAt;
  final String? createdAt;

  ArticleItem({
    required this.id,
    required this.title,
    required this.slug,
    this.excerpt,
    this.coverImageUrl,
    this.categoryId,
    this.categoryName,
    this.authorName,
    this.status = 'published',
    this.contentMarkdown,
    this.publishedAt,
    this.createdAt,
  });

  factory ArticleItem.fromJson(Map<String, dynamic> json) {
    return ArticleItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      excerpt: json['excerpt'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String?,
      authorName: json['author_name'] as String?,
      status: json['status'] as String? ?? 'published',
      contentMarkdown: json['content_markdown'] as String?,
      publishedAt: json['published_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

class CategoryItem {
  final int id;
  final String name;
  final String slug;
  final String? description;

  CategoryItem({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class AnnouncementItem {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isActive;
  final String? startsAt;
  final String? endsAt;
  final String? createdAt;

  AnnouncementItem({
    required this.id,
    required this.title,
    required this.message,
    this.type = 'info',
    this.isActive = true,
    this.startsAt,
    this.endsAt,
    this.createdAt,
  });

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementItem(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'info',
      isActive: json['is_active'] as bool? ?? true,
      startsAt: json['starts_at'] as String?,
      endsAt: json['ends_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
