import 'package:flutter/material.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/features/admin/data/admin_repository.dart';
import 'package:nutriview/shared/neo/neo.dart';

class CategoryManagerModal extends StatefulWidget {
  final AdminRepository adminRepo;
  final VoidCallback onDataChanged;

  const CategoryManagerModal({
    super.key,
    required this.adminRepo,
    required this.onDataChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required AdminRepository adminRepo,
    required VoidCallback onDataChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CategoryManagerModal(
        adminRepo: adminRepo,
        onDataChanged: onDataChanged,
      ),
    );
  }

  @override
  State<CategoryManagerModal> createState() => _CategoryManagerModalState();
}

class _CategoryManagerModalState extends State<CategoryManagerModal> {
  List<dynamic> _categories = [];
  bool _isLoading = false;
  bool _isCreating = false;

  final _nameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final items = await widget.adminRepo.getCategories();
      if (mounted) setState(() => _categories = items);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveCategory() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      NeoSnackBars.error(context, 'Nama kategori wajib diisi.');
      return;
    }

    final slug = _slugCtrl.text.trim().isNotEmpty
        ? _slugCtrl.text.trim().toLowerCase().replaceAll(' ', '-')
        : name.toLowerCase().replaceAll(' ', '-');

    final payload = {
      'name': name,
      'slug': slug,
      'description': _descCtrl.text.trim(),
    };

    setState(() => _isCreating = true);
    try {
      if (_editingId != null) {
        await widget.adminRepo.updateCategory(_editingId!, payload);
        if (mounted) {
          NeoSnackBars.success(context, 'Kategori berhasil diperbarui.');
        }
      } else {
        await widget.adminRepo.createCategory(payload);
        if (mounted) {
          NeoSnackBars.success(context, 'Kategori baru berhasil dibuat.');
        }
      }
      _nameCtrl.clear();
      _slugCtrl.clear();
      _descCtrl.clear();
      _editingId = null;
      await _fetchCategories();
      widget.onDataChanged();
    } catch (e) {
      if (mounted) {
        NeoSnackBars.error(
          context,
          e is ApiException ? e.message : 'Gagal menyimpan kategori: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _deleteCategory(int id, String name) async {
    final confirmed = await NeoDialog.show(
      context,
      title: 'Hapus Kategori?',
      message:
          'Apakah Anda yakin ingin menghapus kategori "$name"? Artikel dengan kategori ini mungkin perlu disesuaikan.',
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
      confirmColor: NeoTokens.alert,
      icon: AppIcons.deleteForever,
    );

    if (confirmed == true && mounted) {
      try {
        await widget.adminRepo.deleteCategory(id);
        if (mounted) {
          NeoSnackBars.success(context, 'Kategori berhasil dihapus.');
        }
        await _fetchCategories();
        widget.onDataChanged();
      } catch (e) {
        if (mounted) {
          NeoSnackBars.error(
            context,
            e is ApiException ? e.message : 'Gagal menghapus kategori: $e',
          );
        }
      }
    }
  }

  void _startEdit(Map<String, dynamic> cat) {
    setState(() {
      _editingId = cat['id'];
      _nameCtrl.text = cat['name'] ?? '';
      _slugCtrl.text = cat['slug'] ?? '';
      _descCtrl.text = cat['description'] ?? '';
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingId = null;
      _nameCtrl.clear();
      _slugCtrl.clear();
      _descCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Row(
                children: [
                  const Icon(AppIcons.category, color: NeoTokens.ink),
                  const SizedBox(width: 8),
                  const Text(
                    'KELOLA KATEGORI CMS',
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
                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(12),
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
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _editingId != null
                              ? 'EDIT KATEGORI'
                              : '+ TAMBAH KATEGORI BARU',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: NeoTokens.ink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        NeoInput(
                          controller: _nameCtrl,
                          label: 'NAMA KATEGORI',
                          hintText: 'misal: Diet Klinis, Tips Gizi',
                        ),
                        const SizedBox(height: 8),
                        NeoInput(
                          controller: _slugCtrl,
                          label: 'SLUG URL (OPSIONAL)',
                          hintText: 'misal: diet-klinis',
                        ),
                        const SizedBox(height: 8),
                        NeoInput(
                          controller: _descCtrl,
                          label: 'DESKRIPSI',
                          hintText: 'Deskripsi singkat kategori ini',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (_editingId != null) ...[
                              Expanded(
                                child: NeoButton(
                                  text: 'Batal Edit',
                                  variant: NeoButtonVariant.secondary,
                                  onPressed: _cancelEdit,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: NeoButton(
                                text: _editingId != null
                                    ? 'Simpan'
                                    : 'Tambah Kategori',
                                prefixIcon: _editingId != null
                                    ? AppIcons.save
                                    : AppIcons.add,
                                variant: NeoButtonVariant.primary,
                                isLoading: _isCreating,
                                onPressed: _saveCategory,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DAFTAR KATEGORI (${_categories.length})',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: NeoTokens.inkSecondary,
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_categories.isEmpty && !_isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: const Text(
                        'Belum ada kategori yang ditambahkan.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: NeoTokens.inkSecondary,
                        ),
                      ),
                    )
                  else
                    ..._categories.map((cat) {
                      final catMap = Map<String, dynamic>.from(cat as Map);
                      final isCurrentEdit = _editingId == catMap['id'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCurrentEdit
                              ? NeoTokens.lime.withValues(alpha: 0.3)
                              : NeoTokens.paper,
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: NeoTokens.hazard.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(
                                  NeoTokens.radiusSmall,
                                ),
                                border: Border.all(
                                  color: NeoTokens.ink,
                                  width: NeoTokens.borderWidthThin,
                                ),
                              ),
                              child: Icon(
                                AppIcons.label,
                                size: AppIcons.sizeMedium,
                                color: NeoTokens.ink,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    catMap['name'] ?? 'Kategori',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: NeoTokens.ink,
                                    ),
                                  ),
                                  Text(
                                    'Slug: ${catMap['slug'] ?? '-'} • ID: ${catMap['id']}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      color: NeoTokens.inkSecondary,
                                    ),
                                  ),
                                  if (catMap['description'] != null &&
                                      catMap['description']
                                          .toString()
                                          .isNotEmpty)
                                    Text(
                                      catMap['description'],
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: NeoTokens.inkSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                AppIcons.edit,
                                size: AppIcons.sizeLarge,
                                color: NeoTokens.cobalt,
                              ),
                              tooltip: 'Edit Kategori',
                              onPressed: () => _startEdit(catMap),
                            ),
                            IconButton(
                              icon: const Icon(
                                AppIcons.delete,
                                size: AppIcons.sizeLarge,
                                color: NeoTokens.alert,
                              ),
                              tooltip: 'Hapus Kategori',
                              onPressed: () => _deleteCategory(
                                catMap['id'],
                                catMap['name'] ?? '',
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
