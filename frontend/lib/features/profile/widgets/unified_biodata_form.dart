import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:oopsieeats/core/age_calculator.dart';
import 'package:oopsieeats/core/app_icons.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/data/models/profile.dart';
import 'package:oopsieeats/features/auth/providers/auth_provider.dart';
import 'package:oopsieeats/features/dashboard/providers/dashboard_provider.dart';
import 'package:oopsieeats/features/profile/providers/profile_provider.dart';
import 'package:oopsieeats/shared/neo/neo.dart';

/// Operational mode for the unified biodata form.
enum BiodataFormMode {
  /// First-time onboarding / mandatory completion right after registration or sign-in.
  /// Form fields start empty (unless auth provides name/email).
  onboarding,

  /// Editing existing biodata from the Profile screen.
  /// Fields are pre-filled with saved user profile metrics from Firestore.
  edit,
}

/// A unified, single source of truth biodata form component for NutriView.
///
/// Ensures 100% visual, layout, spacing, typography, and validation parity between:
/// 1. First-time Onboarding (`CompleteProfileScreen`)
/// 2. Profile Management (`BiodataScreen`)
///
/// Features:
/// - Controlled Neo-Brutalism styling (crisp structural borders, zero-blur hard shadows, tactile matrices).
/// - Dynamic live age calculation pill badge directly derived from birth date.
/// - Tactile segmented chips for Gender selection (Laki-laki / Perempuan) with rounded Material icons.
/// - Side-by-side Height & Weight inputs with dedicated semantic icons.
/// - Tactile card selection with radio-style indicators for Activity Level & Nutrition Goal.
/// - Integrated Profession selector for social identity profile.
/// - Comprehensive UI and business layer validation preventing dummy data submission.
class UnifiedBiodataForm extends StatefulWidget {
  final BiodataFormMode mode;
  final VoidCallback? onSavedSuccessfully;
  final VoidCallback? onCancelOrExit;

  const UnifiedBiodataForm({
    super.key,
    required this.mode,
    this.onSavedSuccessfully,
    this.onCancelOrExit,
  });

  @override
  State<UnifiedBiodataForm> createState() => _UnifiedBiodataFormState();
}

class _UnifiedBiodataFormState extends State<UnifiedBiodataForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  DateTime? _selectedBirthDate;
  String? _birthDateError;
  String? _genderError;
  String? _activityError;
  String? _goalError;

  String _sex = 'male';
  String _activityLevel = 'moderate';
  String _goal = 'maintain_weight';
  String _profession = 'Umum';

  bool _isSaving = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormData();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _initializeFormData() {
    if (!mounted) return;

    AuthProvider? auth;
    try {
      auth = context.read<AuthProvider>();
    } catch (_) {}

    final profileProvider = context.read<ProfileProvider>();
    final user = profileProvider.user ?? auth?.currentUser;
    final profile = profileProvider.profile ?? user?.profile;

    if (widget.mode == BiodataFormMode.edit) {
      // Edit Mode: Pre-fill with user's actual stored data
      if (user != null && user.fullName.isNotEmpty) {
        _nameController.text = user.fullName;
      } else if (auth != null && auth.name.isNotEmpty && auth.name != 'User') {
        _nameController.text = auth.name;
      }

      if (profile != null) {
        if (profile.heightCm > 0) {
          _heightController.text = profile.heightCm.toInt() == profile.heightCm
              ? profile.heightCm.toInt().toString()
              : profile.heightCm.toString();
        }
        if (profile.weightKg > 0) {
          _weightController.text = profile.weightKg.toInt() == profile.weightKg
              ? profile.weightKg.toInt().toString()
              : profile.weightKg.toString();
        }
        if (profile.sex.isNotEmpty) {
          _sex = profile.sex;
        }
        if (profile.activityLevel.isNotEmpty) {
          _activityLevel = profile.activityLevel;
        }
        if (profile.goal.isNotEmpty) {
          _goal = profile.goal;
        }
        if (profile.profession.isNotEmpty) {
          _profession = profile.profession;
        }
        _selectedBirthDate = profile.birthDate;

        // Backward compatibility if birthDate is null but legacy age is set
        if (_selectedBirthDate == null && profile.age > 0) {
          final now = DateTime.now();
          _selectedBirthDate = DateTime(
            now.year - profile.age,
            now.month,
            now.day,
          );
        }
      }
    } else {
      // Onboarding Mode: Fields start clean without artificial dummy numbers
      final credentialName =
          auth?.currentUser?.fullName ??
          profileProvider.user?.fullName ??
          (auth != null && auth.name != 'User' ? auth.name : '');

      if (credentialName.isNotEmpty) {
        _nameController.text = credentialName;
      }

      if (profile != null) {
        if (profile.heightCm > 0) {
          _heightController.text = profile.heightCm.toInt() == profile.heightCm
              ? profile.heightCm.toInt().toString()
              : profile.heightCm.toString();
        }
        if (profile.weightKg > 0) {
          _weightController.text = profile.weightKg.toInt() == profile.weightKg
              ? profile.weightKg.toInt().toString()
              : profile.weightKg.toString();
        }
        if (profile.sex.isNotEmpty) {
          _sex = profile.sex;
        }
        if (profile.activityLevel.isNotEmpty) {
          _activityLevel = profile.activityLevel;
        }
        if (profile.goal.isNotEmpty) {
          _goal = profile.goal;
        }
        if (profile.profession.isNotEmpty) {
          _profession = profile.profession;
        }
        _selectedBirthDate = profile.birthDate;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate =
        _selectedBirthDate ?? DateTime(now.year - 25, now.month, now.day);
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
    // 1. Validate Date of Birth
    final dateError = _selectedBirthDate == null
        ? 'Tanggal lahir wajib dipilih.'
        : AgeCalculator.validateBirthDate(_selectedBirthDate);

    // 2. Validate Gender
    final genderError = _sex.trim().isEmpty
        ? 'Jenis kelamin wajib dipilih.'
        : null;

    // 3. Validate Activity Level
    final activityError = _activityLevel.trim().isEmpty
        ? 'Tingkat aktivitas fisik wajib dipilih.'
        : null;

    // 4. Validate Nutrition Goal
    final goalError = _goal.trim().isEmpty
        ? 'Target gizi wajib dipilih.'
        : null;

    setState(() {
      _birthDateError = dateError;
      _genderError = genderError;
      _activityError = activityError;
      _goalError = goalError;
    });

    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid ||
        dateError != null ||
        genderError != null ||
        activityError != null ||
        goalError != null) {
      NeoSnackBars.error(
        context,
        'Harap periksa dan lengkapi data profil fisik yang masih belum valid.',
      );
      return;
    }

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
      profession: _profession,
    );

    final profileProvider = context.read<ProfileProvider>();
    final success = await profileProvider.saveBiodata(
      fullName: _nameController.text.trim(),
      newProfile: newProfile,
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (success) {
      // Synchronize in-memory auth user profile
      try {
        context.read<AuthProvider>().updateProfile(
          newProfile,
          fullName: _nameController.text.trim(),
        );
      } catch (_) {}

      // Trigger dashboard target calculation refresh
      try {
        final dash = context.read<DashboardProvider>();
        if (profileProvider.dailyTarget != null) {
          dash.updateTargetFromBiodata(profileProvider.dailyTarget!);
        }
        dash.loadDashboard(forceRefresh: true);
      } catch (_) {}

      NeoSnackBars.success(
        context,
        widget.mode == BiodataFormMode.onboarding
            ? 'Profil fisik berhasil disimpan! Target gizi harian Anda telah dihitung.'
            : 'Biodata dan target gizi harian berhasil diperbarui!',
      );

      widget.onSavedSuccessfully?.call();
    } else {
      NeoSnackBars.error(
        context,
        profileProvider.errorMessage ?? 'Gagal menyimpan profil fisik.',
      );
    }
  }

  Future<void> _handleDeleteBiodata() async {
    final confirmed = await NeoDialog.show(
      context,
      title: 'Hapus Biodata Fisik?',
      message: 'Apakah Anda yakin ingin menghapus data biodata fisik (tinggi badan, berat badan, tanggal lahir, dan target gizi)? Akun login dan foto profil Anda tetap aman.',
      confirmText: 'Ya, Hapus',
      cancelText: 'Batal',
      confirmColor: NeoTokens.alert,
      icon: AppIcons.delete,
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isDeleting = true;
      });

      final provider = context.read<ProfileProvider>();
      final success = await provider.deleteBiodata();

      if (!mounted) return;
      setState(() {
        _isDeleting = false;
      });

      if (success) {
        try {
          final dash = context.read<DashboardProvider>();
          dash.handleBiodataDeleted();
          dash.loadDashboard(forceRefresh: true);
        } catch (_) {}
        NeoSnackBars.success(context, 'Biodata fisik berhasil dihapus.');
        Navigator.of(context).pop(true);
      } else {
        NeoSnackBars.error(
          context,
          provider.errorMessage ?? 'Gagal menghapus biodata.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider? auth;
    try {
      auth = Provider.of<AuthProvider?>(context);
    } catch (_) {}

    final profileProvider = context.watch<ProfileProvider>();
    final userEmail =
        auth?.currentUser?.email ??
        auth?.email ??
        profileProvider.user?.email ??
        '';
    final calculatedAge = AgeCalculator.calculateAge(_selectedBirthDate);
    final hasExistingBiodata = profileProvider.profile != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Educational Rationale Card
          _buildEducationalRationaleCard(userEmail),
          const SizedBox(height: NeoTokens.space16),

          // 2. Main Form Card Container
          NeoCard(
            backgroundColor: NeoTokens.white,
            padding: const EdgeInsets.all(NeoTokens.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Field 1: Full Name
                NeoInput(
                  label: 'Nama Lengkap',
                  controller: _nameController,
                  hintText: 'Masukkan nama lengkap Anda',
                  prefixIcon: const Icon(
                    AppIcons.personOutline,
                    size: AppIcons.sizeControl,
                    color: NeoTokens.black,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama lengkap wajib diisi.';
                    }
                    if (val.trim().length < 2) {
                      return 'Nama minimal 2 karakter.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: NeoTokens.space20),

                // Field 2: Gender Selector (Tactile Segmented Chips)
                _buildGenderSelector(),
                const SizedBox(height: NeoTokens.space20),

                // Field 3: Date of Birth & Live Age Pill
                _buildBirthDatePicker(calculatedAge),
                const SizedBox(height: NeoTokens.space20),

                // Field 4: Height & Weight (Side by Side)
                _buildPhysicalMetricsRow(),
                const SizedBox(height: NeoTokens.space20),

                // Field 5: Physical Activity Level Selector
                _buildActivityLevelSelector(),
                const SizedBox(height: NeoTokens.space20),

                // Field 6: Nutrition Goal Selector
                _buildGoalSelector(),
                const SizedBox(height: NeoTokens.space20),

                // Field 7: Profession Selector (Social Profile)
                _buildProfessionSelector(),
              ],
            ),
          ),
          const SizedBox(height: NeoTokens.space20),

          // 3. Policy & Accuracy Guarantee Banner
          _buildPolicyBanner(),
          const SizedBox(height: NeoTokens.space16),

          // 4. Primary Save / Submit Button
          NeoButton(
            text: widget.mode == BiodataFormMode.onboarding
                ? 'Simpan & Lanjutkan'
                : (hasExistingBiodata
                      ? 'Simpan Perubahan Biodata'
                      : 'Simpan Biodata Lengkap'),
            isLoading: _isSaving,
            variant: widget.mode == BiodataFormMode.onboarding
                ? NeoButtonVariant.primary
                : NeoButtonVariant.hazard,
            prefixIcon: widget.mode == BiodataFormMode.edit
                ? AppIcons.save
                : null,
            suffixIcon: widget.mode == BiodataFormMode.onboarding
                ? AppIcons.arrowForward
                : null,
            onPressed: (_isSaving || _isDeleting) ? null : _handleSave,
          ),

          // 5. Secondary Action: Delete Biodata (Edit mode) or Logout/Exit (Onboarding mode)
          if (widget.mode == BiodataFormMode.edit && hasExistingBiodata) ...[
            const SizedBox(height: NeoTokens.space12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: NeoTokens.alert,
                side: const BorderSide(color: NeoTokens.alert, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                ),
              ),
              icon: const Icon(AppIcons.delete, size: AppIcons.sizeLarge),
              label: const Text(
                'Hapus Biodata Fisik',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              onPressed: (_isSaving || _isDeleting)
                  ? null
                  : _handleDeleteBiodata,
            ),
          ] else if (widget.mode == BiodataFormMode.onboarding) ...[
            const SizedBox(height: NeoTokens.space12),
            Center(
              child: TextButton.icon(
                onPressed: _isSaving ? null : widget.onCancelOrExit,
                icon: const Icon(
                  AppIcons.logout,
                  size: AppIcons.sizeControl,
                  color: NeoTokens.alert,
                ),
                label: const Text(
                  'Ganti Akun / Keluar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: NeoTokens.alert,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Informative banner explaining why biometric data is required for caloric calculation.
  Widget _buildEducationalRationaleCard(String email) {
    final isOnboarding = widget.mode == BiodataFormMode.onboarding;

    return NeoCard(
      backgroundColor: NeoTokens.paper,
      padding: const EdgeInsets.all(NeoTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isOnboarding ? NeoTokens.lime : NeoTokens.vividYellow,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                  border: Border.all(
                    color: NeoTokens.black,
                    width: NeoTokens.borderWidth,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: NeoTokens.black,
                      offset: NeoTokens.shadowOffsetSmall,
                      blurRadius: NeoTokens.shadowBlurRadius,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isOnboarding ? AppIcons.calculate : AppIcons.badge,
                    size: AppIcons.sizeHeader,
                    color: NeoTokens.black,
                  ),
                ),
              ),
              const SizedBox(width: NeoTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnboarding
                          ? 'Satu Langkah Terakhir!'
                          : 'Informasi Fisik & Kesehatan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: NeoTokens.black,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space4),
                    Text(
                      isOnboarding
                          ? 'OopsieEats membutuhkan data fisik Anda untuk mengestimasi kebutuhan kalori harian (BMR & TDEE) dan batas makronutrisi secara akurat.'
                          : 'Umur dihitung secara akurat dari tanggal lahir untuk menentukan kebutuhan kalori harianmu secara deterministik.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: NeoTokens.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: NeoTokens.space12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: NeoTokens.space10,
                vertical: NeoTokens.space6,
              ),
              decoration: BoxDecoration(
                color: NeoTokens.recess,
                borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                border: Border.all(
                  color: NeoTokens.black,
                  width: NeoTokens.borderWidthThin,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    AppIcons.email,
                    size: AppIcons.sizeSmall,
                    color: NeoTokens.inkSecondary,
                  ),
                  const SizedBox(width: NeoTokens.space6),
                  Flexible(
                    child: Text(
                      'Akun: $email',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: NeoTokens.inkSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Segmented Neo-Brutalist gender selector with high-contrast tactile feedback.
  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jenis Kelamin',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: NeoTokens.textDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: NeoTokens.space8),
        Row(
          children: [
            Expanded(
              child: _buildGenderOption(
                label: 'Laki-laki',
                value: 'male',
                icon: AppIcons.person,
              ),
            ),
            const SizedBox(width: NeoTokens.space12),
            Expanded(
              child: _buildGenderOption(
                label: 'Perempuan',
                value: 'female',
                icon: AppIcons.face,
              ),
            ),
          ],
        ),
        if (_genderError != null) ...[
          const SizedBox(height: NeoTokens.space6),
          Padding(
            padding: const EdgeInsets.only(left: NeoTokens.space4),
            child: Text(
              _genderError!,
              style: const TextStyle(
                color: NeoTokens.alert,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenderOption({
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _sex == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _sex = value;
          _genderError = null;
        });
      },
      child: AnimatedContainer(
        duration: NeoMotion.durationFast,
        curve: NeoMotion.curveStandard,
        padding: const EdgeInsets.symmetric(
          horizontal: NeoTokens.space14,
          vertical: NeoTokens.space12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? NeoTokens.lime : NeoTokens.paper,
          borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
          border: Border.all(
            color: NeoTokens.black,
            width: isSelected
                ? NeoTokens.borderWidthThick
                : NeoTokens.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: NeoTokens.black,
              offset: isSelected
                  ? NeoTokens.shadowOffsetSmall
                  : NeoTokens.shadowOffsetPressed,
              blurRadius: NeoTokens.shadowBlurRadius,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppIcons.sizeControl, color: NeoTokens.black),
            const SizedBox(width: NeoTokens.space8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: NeoTokens.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Date of birth selector triggering native styled DatePicker with live age calculation.
  Widget _buildBirthDatePicker(int? calculatedAge) {
    final hasError = _birthDateError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tanggal Lahir',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: NeoTokens.textDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: NeoTokens.space8),
        GestureDetector(
          onTap: _pickBirthDate,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: NeoTokens.space16,
              vertical: NeoTokens.space14,
            ),
            decoration: BoxDecoration(
              color: NeoTokens.white,
              borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
              border: Border.all(
                color: hasError ? NeoTokens.alert : NeoTokens.black,
                width: NeoTokens.borderWidth,
              ),
              boxShadow: const [
                BoxShadow(
                  color: NeoTokens.black,
                  offset: NeoTokens.shadowOffsetSmall,
                  blurRadius: NeoTokens.shadowBlurRadius,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  AppIcons.calendarMonth,
                  color: NeoTokens.black,
                  size: AppIcons.sizeControl,
                ),
                const SizedBox(width: NeoTokens.space10),
                Expanded(
                  child: Text(
                    _selectedBirthDate != null
                        ? AgeCalculator.formatIndonesian(_selectedBirthDate)
                        : 'Pilih tanggal lahir',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _selectedBirthDate != null
                          ? NeoTokens.black
                          : NeoTokens.textLight,
                    ),
                  ),
                ),
                if (calculatedAge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: NeoTokens.space8,
                      vertical: NeoTokens.space4,
                    ),
                    decoration: BoxDecoration(
                      color: NeoTokens.hazard,
                      borderRadius: BorderRadius.circular(
                        NeoTokens.radiusSmall,
                      ),
                      border: Border.all(
                        color: NeoTokens.black,
                        width: NeoTokens.borderWidthThin,
                      ),
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
              ],
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: NeoTokens.space6),
          Padding(
            padding: const EdgeInsets.only(left: NeoTokens.space4),
            child: Text(
              _birthDateError!,
              style: const TextStyle(
                color: NeoTokens.alert,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Side-by-side Height and Weight input fields with range constraints.
  Widget _buildPhysicalMetricsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Height Field (cm)
        Expanded(
          child: NeoInput(
            label: 'Tinggi Badan (cm)',
            controller: _heightController,
            hintText: '100 - 250',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(
              AppIcons.fitnessCenter,
              size: AppIcons.sizeControl,
              color: NeoTokens.black,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Wajib diisi';
              }
              final num = double.tryParse(val.trim());
              if (num == null || num < 100 || num > 250) {
                return '100 - 250 cm';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: NeoTokens.space12),

        // Weight Field (kg)
        Expanded(
          child: NeoInput(
            label: 'Berat Badan (kg)',
            controller: _weightController,
            hintText: '30 - 300',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(
              AppIcons.balance,
              size: AppIcons.sizeControl,
              color: NeoTokens.black,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Wajib diisi';
              }
              final num = double.tryParse(val.trim());
              if (num == null || num < 30 || num > 300) {
                return '30 - 300 kg';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// 4-tier Physical Activity Level Selector with tactile cards
  Widget _buildActivityLevelSelector() {
    final activityOptions = [
      _ActivityOption(
        key: 'sedentary',
        title: 'Sedentari',
        subtitle: 'Jarang atau tidak pernah olahraga rutin',
        accentColor: NeoTokens.surfaceMuted,
      ),
      _ActivityOption(
        key: 'light',
        title: 'Ringan',
        subtitle: 'Olahraga ringan 1 - 3 hari per minggu',
        accentColor: NeoTokens.cyan,
      ),
      _ActivityOption(
        key: 'moderate',
        title: 'Sedang',
        subtitle: 'Olahraga intensitas sedang 3 - 5 hari per minggu',
        accentColor: NeoTokens.hazard,
      ),
      _ActivityOption(
        key: 'active',
        title: 'Aktif',
        subtitle: 'Olahraga berat / rutin 6 - 7 hari per minggu',
        accentColor: NeoTokens.lime,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tingkat Aktivitas Fisik',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: NeoTokens.textDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: NeoTokens.space4),
        const Text(
          'Menentukan faktor pengali energi untuk menghitung kebutuhan kalori harian (TDEE).',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: NeoTokens.textMuted,
          ),
        ),
        const SizedBox(height: NeoTokens.space10),
        ...activityOptions.map((opt) {
          final isSelected = _activityLevel == opt.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: NeoTokens.space10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activityLevel = opt.key;
                  _activityError = null;
                });
              },
              child: AnimatedContainer(
                duration: NeoMotion.durationFast,
                curve: NeoMotion.curveStandard,
                padding: const EdgeInsets.all(NeoTokens.space12),
                decoration: BoxDecoration(
                  color: isSelected ? NeoTokens.canvas : NeoTokens.paper,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  border: Border.all(
                    color: NeoTokens.black,
                    width: isSelected
                        ? NeoTokens.borderWidthThick
                        : NeoTokens.borderWidthThin,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NeoTokens.black,
                      offset: isSelected
                          ? NeoTokens.shadowOffsetSmall
                          : Offset.zero,
                      blurRadius: NeoTokens.shadowBlurRadius,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? opt.accentColor : NeoTokens.paper,
                        border: Border.all(
                          color: NeoTokens.black,
                          width: NeoTokens.borderWidth,
                        ),
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(
                                AppIcons.checkCircle,
                                size: AppIcons.sizeMicro,
                                color: NeoTokens.black,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: NeoTokens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: NeoTokens.black,
                            ),
                          ),
                          const SizedBox(height: NeoTokens.space2),
                          Text(
                            opt.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: NeoTokens.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (_activityError != null) ...[
          const SizedBox(height: NeoTokens.space4),
          Padding(
            padding: const EdgeInsets.only(left: NeoTokens.space4),
            child: Text(
              _activityError!,
              style: const TextStyle(
                color: NeoTokens.alert,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Nutrition goal selector (Maintain, Lose, Gain weight)
  Widget _buildGoalSelector() {
    final goalOptions = [
      _GoalOption(
        key: 'lose_weight',
        title: 'Menurunkan Berat Badan',
        subtitle: 'Defisit kalori sehat terukur (-500 kcal/hari)',
        accentColor: NeoTokens.coralRed,
      ),
      _GoalOption(
        key: 'maintain_weight',
        title: 'Mempertahankan Berat Badan',
        subtitle: 'Keseimbangan asupan energi harian stabil',
        accentColor: NeoTokens.lime,
      ),
      _GoalOption(
        key: 'gain_weight',
        title: 'Menambah Berat Badan',
        subtitle: 'Surplus kalori terkontrol (+500 kcal/hari)',
        accentColor: NeoTokens.vividYellow,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Target Gizi & Berat Badan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: NeoTokens.textDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: NeoTokens.space4),
        const Text(
          'Menyesuaikan rekomendasi total kalori dan distribusi makronutrisi harian Anda.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: NeoTokens.textMuted,
          ),
        ),
        const SizedBox(height: NeoTokens.space10),
        ...goalOptions.map((opt) {
          final isSelected = _goal == opt.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: NeoTokens.space10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _goal = opt.key;
                  _goalError = null;
                });
              },
              child: AnimatedContainer(
                duration: NeoMotion.durationFast,
                curve: NeoMotion.curveStandard,
                padding: const EdgeInsets.all(NeoTokens.space12),
                decoration: BoxDecoration(
                  color: isSelected ? NeoTokens.canvas : NeoTokens.paper,
                  borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
                  border: Border.all(
                    color: NeoTokens.black,
                    width: isSelected
                        ? NeoTokens.borderWidthThick
                        : NeoTokens.borderWidthThin,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: NeoTokens.black,
                      offset: isSelected
                          ? NeoTokens.shadowOffsetSmall
                          : Offset.zero,
                      blurRadius: NeoTokens.shadowBlurRadius,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? opt.accentColor : NeoTokens.paper,
                        border: Border.all(
                          color: NeoTokens.black,
                          width: NeoTokens.borderWidth,
                        ),
                      ),
                      child: isSelected
                          ? const Center(
                              child: Icon(
                                AppIcons.checkCircle,
                                size: AppIcons.sizeMicro,
                                color: NeoTokens.black,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: NeoTokens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: NeoTokens.black,
                            ),
                          ),
                          const SizedBox(height: NeoTokens.space2),
                          Text(
                            opt.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: NeoTokens.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (_goalError != null) ...[
          const SizedBox(height: NeoTokens.space4),
          Padding(
            padding: const EdgeInsets.only(left: NeoTokens.space4),
            child: Text(
              _goalError!,
              style: const TextStyle(
                color: NeoTokens.alert,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Profession Selector (Social Profile attribute)
  Widget _buildProfessionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Profesi / Pekerjaan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: NeoTokens.textDark,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: NeoTokens.mintGreen,
                borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
                border: Border.all(color: NeoTokens.black, width: 1),
              ),
              child: const Text(
                'PROFIL SOSIAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: NeoTokens.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: NeoTokens.space4),
        const Text(
          'Profesi ini murni informasi profil dan tidak mengubah hak akses akun.',
          style: TextStyle(fontSize: 11, color: NeoTokens.textMuted),
        ),
        const SizedBox(height: NeoTokens.space8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: NeoTokens.white,
            borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
            border: Border.all(
              color: NeoTokens.black,
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
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: UserProfile.predefinedProfessions.contains(_profession)
                  ? _profession
                  : 'Lainnya',
              dropdownColor: NeoTokens.white,
              borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
              icon: const Icon(
                AppIcons.arrowDropDown,
                color: NeoTokens.black,
                size: AppIcons.sizeHeader,
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: NeoTokens.black,
              ),
              items: UserProfile.predefinedProfessions
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          const Icon(
                            AppIcons.businessCenter,
                            size: AppIcons.sizeSmall,
                            color: NeoTokens.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            p,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: NeoTokens.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _profession = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  /// High-visibility callout explaining policy and accuracy guarantee.
  Widget _buildPolicyBanner() {
    final isOnboarding = widget.mode == BiodataFormMode.onboarding;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: NeoTokens.space12,
        vertical: NeoTokens.space10,
      ),
      decoration: BoxDecoration(
        color: NeoTokens.recess,
        borderRadius: BorderRadius.circular(NeoTokens.radiusMedium),
        border: Border.all(
          color: NeoTokens.black,
          width: NeoTokens.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.info,
            size: AppIcons.sizeLarge,
            color: NeoTokens.inkSecondary,
          ),
          const SizedBox(width: NeoTokens.space8),
          Expanded(
            child: Text(
              isOnboarding
                  ? 'Profil ini wajib dilengkapi sebelum masuk ke dashboard agar analisis gizi tidak bias atau kosong.'
                  : 'Target gizi harian (BMR & TDEE) akan langsung dikalkulasi ulang secara otomatis setelah perubahan disimpan.',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: NeoTokens.inkSecondary,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityOption {
  final String key;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _ActivityOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}

class _GoalOption {
  final String key;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _GoalOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}
