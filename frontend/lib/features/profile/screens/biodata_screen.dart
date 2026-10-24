import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/age_calculator.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/features/dashboard/providers/dashboard_provider.dart';
import 'package:nutriview/features/profile/providers/profile_provider.dart';
import 'package:nutriview/shared/neo/neo.dart';
import 'package:nutriview/shared/widgets/custom_button.dart';
import 'package:nutriview/shared/widgets/custom_text_field.dart';

/// Dedicated screen for managing user biodata with full CRUD and accurate
/// birth-date-driven age calculation.
class BiodataScreen extends StatefulWidget {
  const BiodataScreen({super.key});

  @override
  State<BiodataScreen> createState() => _BiodataScreenState();
}

class _BiodataScreenState extends State<BiodataScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _selectedBirthDate;
  String? _birthDateError;
  String _sex = 'male';
  String _activityLevel = 'moderate';
  String _goal = 'maintain_weight';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.user;
    final profile = profileProvider.profile;

    if (user != null) {
      _nameController.text = user.fullName;
    }

    if (profile != null) {
      _heightController.text = profile.heightCm.toString();
      _weightController.text = profile.weightKg.toString();
      _sex = profile.sex;
      _activityLevel = profile.activityLevel;
      _goal = profile.goal;
      _selectedBirthDate = profile.birthDate;

      // Backward compatibility if birthDate is null but age is set
      if (_selectedBirthDate == null && profile.age > 0) {
        final now = DateTime.now();
        _selectedBirthDate = DateTime(now.year - profile.age, now.month, now.day);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(now.year - 25, now.month, now.day);
    final firstDate = DateTime(now.year - AgeCalculator.maxAge, 1, 1);
    final lastDate = now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(lastDate) ? lastDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'PILIH TANGGAL LAHIR',
      confirmText: 'PILIH',
      cancelText: 'BATAL',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: NeoTokens.black,
              onPrimary: NeoTokens.vividYellow,
              surface: NeoTokens.warmBackground,
              onSurface: NeoTokens.black,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      final error = AgeCalculator.validateBirthDate(picked);
      setState(() {
        _selectedBirthDate = picked;
        _birthDateError = error;
      });
    }
  }

  Future<void> _handleSave() async {
    // Validate birth date
    final dateError = AgeCalculator.validateBirthDate(_selectedBirthDate);
    if (dateError != null) {
      setState(() {
        _birthDateError = dateError;
      });
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final height = double.parse(_heightController.text.trim());
    final weight = double.parse(_weightController.text.trim());
    final age = AgeCalculator.calculateAge(_selectedBirthDate)!;

    final newProfile = UserProfile(
      age: age,
      birthDate: _selectedBirthDate,
      sex: _sex,
      weightKg: weight,
      heightCm: height,
      activityLevel: _activityLevel,
      goal: _goal,
    );

    final provider = context.read<ProfileProvider>();
    final success = await provider.saveBiodata(
      fullName: _nameController.text.trim(),
      newProfile: newProfile,
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (success) {
      // Trigger dashboard refresh so targets update immediately
      context.read<DashboardProvider>().loadDashboard();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: NeoTokens.black,
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: NeoTokens.mintGreen, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Biodata dan target gizi harian berhasil disimpan!',
                  style: TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.white),
                ),
              ),
            ],
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: NeoTokens.alert,
          content: Text(provider.errorMessage ?? 'Gagal menyimpan biodata.'),
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await NeoDialog.show(
      context,
      title: 'Hapus Biodata Fisik?',
      message:
          'Apakah Anda yakin ingin menghapus data biodata fisik (tinggi badan, berat badan, tanggal lahir, dan target gizi)? Akun login dan avatar Anda tetap aman.',
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
      confirmColor: NeoTokens.alert,
      icon: Icons.delete_outline_rounded,
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isSaving = true;
      });

      final provider = context.read<ProfileProvider>();
      final success = await provider.deleteBiodata();

      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });

      if (success) {
        context.read<DashboardProvider>().loadDashboard();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: NeoTokens.black,
            content: Text(
              'Biodata fisik berhasil dihapus.',
              style: TextStyle(color: NeoTokens.white, fontWeight: FontWeight.w700),
            ),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: NeoTokens.alert,
            content: Text(provider.errorMessage ?? 'Gagal menghapus biodata.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final hasExistingBiodata = profileProvider.profile != null;
    final calculatedAge = AgeCalculator.calculateAge(_selectedBirthDate);

    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        title: const Text('Kelola Biodata'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: NeoTokens.black, height: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: NeoTokens.space16,
          vertical: NeoTokens.space16,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Intro banner
              NeoCard(
                backgroundColor: NeoTokens.paper,
                padding: const EdgeInsets.all(NeoTokens.space16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: NeoTokens.vividYellow,
                        borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                        border: Border.all(color: NeoTokens.black, width: 2),
                      ),
                      child: const Icon(Icons.badge_rounded, color: NeoTokens.black, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Fisik & Kesehatan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: NeoTokens.black,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Umur dihitung secara akurat dari tanggal lahir untuk menentukan kebutuhan kalori harianmu.',
                            style: TextStyle(fontSize: 11.5, color: NeoTokens.textMuted, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NeoTokens.space16),

              // Form card
              NeoCard(
                backgroundColor: NeoTokens.white,
                padding: const EdgeInsets.all(NeoTokens.space20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Display Name
                    CustomTextField(
                      label: 'Nama Lengkap / Tampilan',
                      controller: _nameController,
                      hintText: 'Masukkan nama lengkap',
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Nama lengkap wajib diisi';
                        }
                        if (val.trim().length < 2) {
                          return 'Nama minimal 2 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: NeoTokens.space16),

                    // Date of Birth Field & Dynamic Age Display
                    const Text(
                      'Tanggal Lahir',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: NeoTokens.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space8),
                    GestureDetector(
                      onTap: _pickBirthDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: NeoTokens.white,
                          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                          border: Border.all(
                            color: _birthDateError != null ? NeoTokens.alert : NeoTokens.black,
                            width: NeoTokens.borderWidth,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: NeoTokens.black,
                              offset: NeoTokens.shadowOffsetSmall,
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded, color: NeoTokens.black, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedBirthDate != null
                                    ? DateFormat('d MMMM yyyy', 'id_ID').format(_selectedBirthDate!)
                                    : 'Pilih Tanggal Lahir',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _selectedBirthDate != null
                                      ? NeoTokens.black
                                      : NeoTokens.textLight,
                                ),
                              ),
                            ),
                            if (calculatedAge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: NeoTokens.vividYellow,
                                  borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                                  border: Border.all(color: NeoTokens.black, width: 1.5),
                                ),
                                child: Text(
                                  'Usia: $calculatedAge thn',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: NeoTokens.black,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (_birthDateError != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _birthDateError!,
                        style: const TextStyle(
                          color: NeoTokens.alert,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: NeoTokens.space16),

                    // Gender Selection
                    const Text(
                      'Jenis Kelamin',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: NeoTokens.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space8),
                    _buildDropdownContainer(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _sex,
                        dropdownColor: NeoTokens.white,
                        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: NeoTokens.black, size: 26),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: NeoTokens.black),
                        items: const [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text('Laki-laki', style: TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.black)),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Perempuan', style: TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.black)),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _sex = val);
                        },
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space16),

                    // Height & Weight Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Tinggi Badan (cm)',
                            controller: _heightController,
                            hintText: '100 - 250',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                              final num = double.tryParse(val.trim());
                              if (num == null || num < 100 || num > 250) {
                                return '100-250 cm';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: NeoTokens.space12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Berat Badan (kg)',
                            controller: _weightController,
                            hintText: '30 - 300',
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Wajib diisi';
                              final num = double.tryParse(val.trim());
                              if (num == null || num < 30 || num > 300) {
                                return '30-300 kg';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: NeoTokens.space16),

                    // Activity Level
                    const Text(
                      'Tingkat Aktivitas Harian',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: NeoTokens.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space8),
                    _buildDropdownContainer(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _activityLevel,
                        dropdownColor: NeoTokens.white,
                        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: NeoTokens.black, size: 26),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: NeoTokens.black),
                        items: const [
                          DropdownMenuItem(
                            value: 'sedentary',
                            child: Text('Sedentari (jarang olahraga)', style: TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.black)),
                          ),
                          DropdownMenuItem(
                            value: 'light',
                            child: Text('Ringan (olahraga 1-3 hari/minggu)', style: TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.black)),
                          ),
                          DropdownMenuItem(
                            value: 'moderate',
                            child: Text('Sedang (olahraga 3-5 hari/minggu)', style: TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.black)),
                          ),
                          DropdownMenuItem(
                            value: 'active',
                            child: Text('Aktif (olahraga 6-7 hari/minggu)', style: TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.black)),
                          ),
                          DropdownMenuItem(
                            value: 'very_active',
                            child: Text('Sangat Aktif (latihan fisik berat)', style: TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.black)),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _activityLevel = val);
                        },
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space16),

                    // Nutrition Goal
                    const Text(
                      'Tujuan Gizi',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: NeoTokens.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space8),
                    _buildDropdownContainer(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _goal,
                        dropdownColor: NeoTokens.white,
                        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                        icon: const Icon(Icons.arrow_drop_down_rounded, color: NeoTokens.black, size: 26),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: NeoTokens.black),
                        items: const [
                          DropdownMenuItem(
                            value: 'lose_weight',
                            child: Text('Menurunkan Berat Badan', style: TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.black)),
                          ),
                          DropdownMenuItem(
                            value: 'maintain_weight',
                            child: Text('Mempertahankan Berat Badan', style: TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.black)),
                          ),
                          DropdownMenuItem(
                            value: 'gain_weight',
                            child: Text('Menambah Berat Badan', style: TextStyle(fontWeight: FontWeight.w700, color: NeoTokens.black)),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _goal = val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: NeoTokens.space20),

              // Action Buttons
              CustomButton(
                text: hasExistingBiodata ? 'Simpan Perubahan Biodata' : 'Simpan Biodata Lengkap',
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _handleSave,
              ),

              if (hasExistingBiodata) ...[
                const SizedBox(height: NeoTokens.space12),
                OutlinedButton.styleFrom(
                  foregroundColor: NeoTokens.alert,
                  side: const BorderSide(color: NeoTokens.alert, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  ),
                ).let(
                  (style) => OutlinedButton.icon(
                    style: style,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text(
                      'Hapus Biodata Fisik',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    onPressed: _isSaving ? null : _handleDelete,
                  ),
                ),
              ],
              const SizedBox(height: NeoTokens.space56),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: NeoTokens.white,
        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
        border: Border.all(color: NeoTokens.black, width: NeoTokens.borderWidth),
        boxShadow: const [
          BoxShadow(
            color: NeoTokens.black,
            offset: NeoTokens.shadowOffsetSmall,
            blurRadius: 0,
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }
}

extension _LetExt<T> on T {
  R let<R>(R Function(T it) op) => op(this);
}
