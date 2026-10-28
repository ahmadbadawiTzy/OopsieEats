import 'package:flutter/material.dart';
import 'package:nutriview/core/app_icons.dart';
import 'package:nutriview/core/error_handler.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/features/admin/data/admin_repository.dart';
import 'package:nutriview/shared/neo/neo.dart';

class MediaManagerModal extends StatefulWidget {
  final AdminRepository adminRepo;
  final VoidCallback onDataChanged;

  const MediaManagerModal({
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
      builder: (ctx) =>
          MediaManagerModal(adminRepo: adminRepo, onDataChanged: onDataChanged),
    );
  }

  @override
  State<MediaManagerModal> createState() => _MediaManagerModalState();
}

class _MediaManagerModalState extends State<MediaManagerModal> {
  List<dynamic> _mediaList = [];
  bool _isLoading = false;
  bool _isUploading = false;

  final _filenameCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMedia();
  }

  @override
  void dispose() {
    _filenameCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchMedia() async {
    setState(() => _isLoading = true);
    try {
      final res = await widget.adminRepo.getMedia(limit: 50);
      if (mounted) {
        setState(() => _mediaList = res['items'] as List<dynamic>? ?? []);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadMedia() async {
    final filename = _filenameCtrl.text.trim();
    final url = _urlCtrl.text.trim();

    if (filename.isEmpty) {
      NeoSnackBars.error(context, 'Nama file wajib diisi.');
      return;
    }

    setState(() => _isUploading = true);
    try {
      // Create mock binary bytes for metadata recording
      final bytes = List<int>.filled(1024 * 45, 0); // 45 KB representation
      await widget.adminRepo.uploadMedia(
        bytes,
        filename,
        mediaUrl: url.isNotEmpty ? url : null,
      );
      if (mounted) {
        NeoSnackBars.success(context, 'Aset media berhasil didaftarkan.');
      }
      _filenameCtrl.clear();
      _urlCtrl.clear();
      await _fetchMedia();
      widget.onDataChanged();
    } catch (e) {
      if (mounted) {
        NeoSnackBars.error(
          context,
          e is ApiException ? e.message : 'Gagal mengunggah media: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteMedia(int id, String filename) async {
    final confirmed = await NeoDialog.show(
      context,
      title: 'Hapus Aset Media?',
      message:
          'Apakah Anda yakin ingin menghapus media "$filename"? URL aset ini tidak akan dapat diakses kembali.',
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
      confirmColor: NeoTokens.alert,
      icon: AppIcons.deleteForever,
    );

    if (confirmed == true && mounted) {
      try {
        await widget.adminRepo.deleteMedia(id);
        if (mounted) {
          NeoSnackBars.success(context, 'Aset media berhasil dihapus.');
        }
        await _fetchMedia();
        widget.onDataChanged();
      } catch (e) {
        if (mounted) {
          NeoSnackBars.error(
            context,
            e is ApiException ? e.message : 'Gagal menghapus media: $e',
          );
        }
      }
    }
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
              const Row(
                children: [
                  Icon(AppIcons.photoLibrary, color: NeoTokens.ink),
                  SizedBox(width: 8),
                  Text(
                    'GALERI ASET MEDIA CMS',
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
                  // Upload / Register Form
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
                        const Text(
                          '+ DAFTARKAN ASET GAMBAR / MEDIA',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: NeoTokens.ink,
                          ),
                        ),
                        const SizedBox(height: 10),
                        NeoInput(
                          controller: _filenameCtrl,
                          label: 'NAMA FILE',
                          hintText: 'misal: banner_gizi_seimbang.webp',
                        ),
                        const SizedBox(height: 8),
                        NeoInput(
                          controller: _urlCtrl,
                          label: 'URL GAMBAR (OPSIONAL / DEFAULT UNSPLASH)',
                          hintText: 'https://images.unsplash.com/...',
                        ),
                        const SizedBox(height: 12),
                        NeoButton(
                          text: 'Daftarkan Media',
                          prefixIcon: AppIcons.cloudUpload,
                          variant: NeoButtonVariant.primary,
                          isLoading: _isUploading,
                          onPressed: _uploadMedia,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Media List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ASET TERSIMPAN (${_mediaList.length})',
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

                  if (_mediaList.isEmpty && !_isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      child: const Text(
                        'Belum ada aset media yang tersimpan.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: NeoTokens.inkSecondary,
                        ),
                      ),
                    )
                  else
                    ..._mediaList.map((m) {
                      final mediaMap = Map<String, dynamic>.from(m as Map);
                      final url = mediaMap['url'] as String? ?? '';
                      final filename =
                          mediaMap['filename'] as String? ?? 'Asset';
                      final id = (mediaMap['id'] as num?)?.toInt() ?? 0;
                      final sizeBytes =
                          (mediaMap['file_size'] as num?)?.toInt() ?? 0;
                      final sizeKB = (sizeBytes / 1024).toStringAsFixed(1);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
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
                              offset: Offset(1.5, 1.5),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Thumbnail
                            Container(
                              width: 50,
                              height: 50,
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
                              clipBehavior: Clip.antiAlias,
                              child: url.isNotEmpty
                                  ? Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        AppIcons.image,
                                        size: AppIcons.sizeHeader,
                                        color: NeoTokens.inkSecondary,
                                      ),
                                    )
                                  : const Icon(
                                      AppIcons.image,
                                      size: AppIcons.sizeHeader,
                                      color: NeoTokens.inkSecondary,
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filename,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: NeoTokens.ink,
                                    ),
                                  ),
                                  Text(
                                    'Ukuran: $sizeKB KB • ID: $id',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      color: NeoTokens.inkSecondary,
                                    ),
                                  ),
                                  Text(
                                    url,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: NeoTokens.cobalt,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                AppIcons.delete,
                                size: AppIcons.sizeLarge,
                                color: NeoTokens.alert,
                              ),
                              tooltip: 'Hapus Media',
                              onPressed: () => _deleteMedia(id, filename),
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
