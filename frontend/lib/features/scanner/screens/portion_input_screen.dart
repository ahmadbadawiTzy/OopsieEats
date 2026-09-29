import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/core/theme.dart';
import 'package:nutriview/features/dashboard/providers/dashboard_provider.dart';
import 'package:nutriview/features/scanner/providers/scan_flow_provider.dart';
import 'package:nutriview/shared/widgets/custom_button.dart';

class PortionInputScreen extends StatefulWidget {
  const PortionInputScreen({super.key});

  @override
  State<PortionInputScreen> createState() => _PortionInputScreenState();
}

class _PortionInputScreenState extends State<PortionInputScreen> {
  final Map<int, TextEditingController> _controllers = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final items = context.read<ScanFlowProvider>().confirmedItems;
    for (int i = 0; i < items.length; i++) {
      final portion = items[i].portionGrams;
      _controllers[i] = TextEditingController(
        text: portion != null ? portion.toString() : '',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final flow = context.read<ScanFlowProvider>();
    for (int i = 0; i < flow.confirmedItems.length; i++) {
      final text = _controllers[i]?.text.trim() ?? '';
      final grams = double.tryParse(text) ?? 0.0;
      flow.updatePortion(i, grams);
    }

    final success = await flow.submitMeal();
    if (success && mounted) {
      // Refresh dashboard
      context.read<DashboardProvider>().loadDashboard();
      Navigator.pushReplacementNamed(context, AppRoutes.mealResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<ScanFlowProvider>();
    final items = flow.confirmedItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Porsi Makanan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Meal Type Selector
                    const Text(
                      'Jenis Waktu Makan',
                      style: TextStyle(
                        fontSize: 14,
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
                          value: flow.mealType,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textDark,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'breakfast', child: Text('Sarapan')),
                            DropdownMenuItem(value: 'lunch', child: Text('Makan Siang')),
                            DropdownMenuItem(value: 'dinner', child: Text('Makan Malam')),
                            DropdownMenuItem(value: 'snack', child: Text('Camilan')),
                          ],
                          onChanged: (val) {
                            if (val != null) flow.setMealType(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (flow.errorMessage != null) ...[
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
                                flow.errorMessage!,
                                style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text(
                      'Masukkan Porsi (dalam gram)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Nilai awal porsi tidak ditebak oleh sistem. Masukkan perkiraan berat porsi Anda.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
                    ),
                    const SizedBox(height: 12),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final controller = _controllers[index] ??= TextEditingController();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreenLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_rounded,
                                    size: 18,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.foodName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textDark,
                                          letterSpacing: -0.1,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.source == 'detected'
                                            ? 'Terdeteksi'
                                            : item.source == 'corrected'
                                                ? 'Dikoreksi'
                                                : 'Manual',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: controller,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textDark,
                                    ),
                                    decoration: const InputDecoration(
                                      suffixText: 'g',
                                      suffixStyle: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textMuted,
                                      ),
                                      hintText: '150',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Wajib diisi';
                                      }
                                      final num = double.tryParse(val.trim());
                                      if (num == null || num <= 0 || num > 5000) {
                                        return '1-5000 g';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
            ),
            child: SafeArea(
              child: CustomButton(
                text: 'Simpan & Hitung Gizi',
                icon: Icons.check_circle_outline_rounded,
                isLoading: flow.isProcessing,
                onPressed: _handleSave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
