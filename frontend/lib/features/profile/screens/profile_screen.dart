import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/data/models/profile.dart';
import 'package:nutriview/features/profile/providers/profile_provider.dart';
import 'package:nutriview/shared/widgets/custom_button.dart';
import 'package:nutriview/shared/widgets/custom_text_field.dart';
import 'package:nutriview/shared/widgets/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  String _sex = 'male';
  String _activityLevel = 'moderate';
  String _goal = 'maintain_weight';
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProfileProvider>();
      await provider.loadProfile();
      if (!mounted) return;
      final profile = provider.profile;
      if (profile != null) {
        setState(() {
          _ageController.text = profile.age.toString();
          _weightController.text = profile.weightKg.toString();
          _heightController.text = profile.heightCm.toString();
          _sex = profile.sex;
          _activityLevel = profile.activityLevel;
          _goal = profile.goal;
          _initialized = true;
        });
      } else {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final age = int.parse(_ageController.text.trim());
    final weight = double.parse(_weightController.text.trim());
    final height = double.parse(_heightController.text.trim());

    final profile = UserProfile(
      age: age,
      sex: _sex,
      weightKg: weight,
      heightCm: height,
      activityLevel: _activityLevel,
      goal: _goal,
    );

    final provider = context.read<ProfileProvider>();
    final success = await provider.saveProfile(profile);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil dan target gizi harian berhasil disimpan!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    if (!_initialized && profileProvider.isLoading) {
      return const Scaffold(
        body: LoadingIndicator(message: 'Memuat profil...'),
      );
    }

    final target = profileProvider.dailyTarget;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (target != null) ...[
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreenLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt_rounded, color: AppTheme.primaryGreen, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Target Gizi Harian Anda',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryGreenDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _targetChip('Kalori', '${target.caloriesKcal} kkal'),
                          _targetChip('Protein', '${target.proteinG}g'),
                          _targetChip('Karbo', '${target.carbsG}g'),
                          _targetChip('Lemak', '${target.fatG}g'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'BMR: ${target.bmrKcal} kkal • TDEE: ${target.tdeeKcal} kkal',
                        style: const TextStyle(fontSize: 11, color: AppTheme.primaryGreenDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (profileProvider.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRedLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppTheme.errorRed, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          profileProvider.errorMessage!,
                          style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Usia (Tahun)',
                      controller: _ageController,
                      hintText: '15 - 100',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Wajib diisi';
                        final num = int.tryParse(val);
                        if (num == null || num < 15 || num > 100) {
                          return '15-100 tahun';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jenis Kelamin',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _sex,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textDark,
                              ),
                              items: const [
                                DropdownMenuItem(value: 'male', child: Text('Laki-laki')),
                                DropdownMenuItem(value: 'female', child: Text('Perempuan')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _sex = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Berat Badan (kg)',
                      controller: _weightController,
                      hintText: '20 - 300',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Wajib diisi';
                        final num = double.tryParse(val);
                        if (num == null || num < 20 || num > 300) {
                          return '20-300 kg';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: CustomTextField(
                      label: 'Tinggi Badan (cm)',
                      controller: _heightController,
                      hintText: '100 - 250',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Wajib diisi';
                        final num = double.tryParse(val);
                        if (num == null || num < 100 || num > 250) {
                          return '100-250 cm';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Tingkat Aktivitas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _activityLevel,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'sedentary',
                        child: Text('Sedentari (Jarang olahraga)'),
                      ),
                      DropdownMenuItem(
                        value: 'light',
                        child: Text('Ringan (Olahraga 1-3 hari/minggu)'),
                      ),
                      DropdownMenuItem(
                        value: 'moderate',
                        child: Text('Sedang (Olahraga 3-5 hari/minggu)'),
                      ),
                      DropdownMenuItem(
                        value: 'active',
                        child: Text('Aktif (Olahraga 6-7 hari/minggu)'),
                      ),
                      DropdownMenuItem(
                        value: 'very_active',
                        child: Text('Sangat Aktif (Latihan fisik berat)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _activityLevel = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tujuan Gizi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                  letterSpacing: -0.1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _goal,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'lose_weight',
                        child: Text('Menurunkan Berat Badan'),
                      ),
                      DropdownMenuItem(
                        value: 'maintain_weight',
                        child: Text('Mempertahankan Berat Badan'),
                      ),
                      DropdownMenuItem(
                        value: 'gain_weight',
                        child: Text('Menambah Berat Badan'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _goal = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Simpan Profil',
                icon: Icons.save_outlined,
                isLoading: profileProvider.isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _targetChip(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
