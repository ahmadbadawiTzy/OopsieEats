import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nutriview/core/neo_tokens.dart';
import 'package:nutriview/core/routes.dart';
import 'package:nutriview/features/dashboard/providers/dashboard_provider.dart';
import 'package:nutriview/features/scanner/providers/scan_flow_provider.dart';
import 'package:nutriview/shared/neo/neo_back_button.dart';
import 'package:nutriview/shared/neo/neo_badge.dart';
import 'package:nutriview/shared/neo/neo_button.dart';
import 'package:nutriview/shared/neo/neo_card.dart';
import 'package:nutriview/shared/neo/neo_section_header.dart';
import 'package:nutriview/core/app_icons.dart';

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
      final portion = items[i].portionGrams ?? 150.0;
      if (items[i].portionGrams == null) {
        items[i].portionGrams = 150.0;
      }
      _controllers[i] = TextEditingController(text: portion.toInt().toString());
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onGramsChanged(int index, String val) {
    final grams = double.tryParse(val.trim());
    if (grams != null && grams > 0) {
      context.read<ScanFlowProvider>().updatePortion(index, grams);
    } else {
      context.read<ScanFlowProvider>().updatePortion(index, 0);
    }
  }

  void _setQuickPortion(int index, double grams) {
    _controllers[index]?.text = grams.toInt().toString();
    context.read<ScanFlowProvider>().updatePortion(index, grams);
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

  Widget _buildPortionChip(
    int index,
    String label,
    double grams,
    double currentGrams,
  ) {
    final isSelected = (currentGrams - grams).abs() < 0.1;
    return GestureDetector(
      onTap: () => _setQuickPortion(index, grams),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? NeoTokens.vividYellow : NeoTokens.white,
          borderRadius: BorderRadius.circular(NeoTokens.radiusSmall),
          border: Border.all(
            color: NeoTokens.black,
            width: NeoTokens.borderWidthThin,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: NeoTokens.black,
                    offset: Offset(1.5, 1.5),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: NeoTokens.black,
          ),
        ),
      ),
    );
  }

  Widget _buildMacroItem(
    String label,
    String value,
    Color dotColor, {
    bool isBold = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: NeoTokens.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w800,
            color: NeoTokens.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryMacro(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: NeoTokens.black,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: NeoTokens.black,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: NeoTokens.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<ScanFlowProvider>();
    final items = flow.confirmedItems;

    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        leading: NeoBackButton.leading(context),
        title: const Text('Input Porsi Makanan'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: NeoTokens.black, height: 2),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: NeoTokens.space16,
                vertical: NeoTokens.space12,
              ),
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
                        fontWeight: FontWeight.w800,
                        color: NeoTokens.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: NeoTokens.white,
                        borderRadius: BorderRadius.circular(
                          NeoTokens.radiusMedium,
                        ),
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
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: flow.mealType,
                          icon: const Icon(
                            AppIcons.arrowDropDown,
                            color: NeoTokens.black,
                            size: AppIcons.sizeHeader,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: NeoTokens.textDark,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'breakfast',
                              child: Text('Sarapan'),
                            ),
                            DropdownMenuItem(
                              value: 'lunch',
                              child: Text('Makan Siang'),
                            ),
                            DropdownMenuItem(
                              value: 'dinner',
                              child: Text('Makan Malam'),
                            ),
                            DropdownMenuItem(
                              value: 'snack',
                              child: Text('Camilan'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) flow.setMealType(val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: NeoTokens.space20),

                    if (flow.errorMessage != null) ...[
                      NeoCard(
                        backgroundColor: NeoTokens.coralRed,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shadowOffset: NeoTokens.shadowOffsetSmall,
                        child: Row(
                          children: [
                            const Icon(
                              AppIcons.error,
                              color: NeoTokens.white,
                              size: AppIcons.sizeToolbar,
                            ),
                            const SizedBox(width: NeoTokens.space12),
                            Expanded(
                              child: Text(
                                flow.errorMessage!,
                                style: const TextStyle(
                                  color: NeoTokens.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: NeoTokens.space16),
                    ],

                    const NeoSectionHeader(
                      title: 'Atur Porsi Makanan (gram)',
                      subtitle: 'Pilih preset porsi cepat atau ketik gramatur manual untuk melihat estimasi gizi langsung.',
                      accentColor: NeoTokens.mintGreen,
                    ),
                    const SizedBox(height: NeoTokens.space8),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final confirmedItem = items[index];
                        final controller = _controllers[index] ??=
                            TextEditingController();
                        final currentGrams = confirmedItem.portionGrams ?? 0.0;

                        return NeoCard(
                          margin: const EdgeInsets.symmetric(
                            vertical: NeoTokens.space6,
                          ),
                          padding: const EdgeInsets.all(NeoTokens.space14),
                          shadowOffset: NeoTokens.shadowOffsetSmall,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: NeoTokens.vividYellow,
                                      borderRadius: BorderRadius.circular(
                                        NeoTokens.radiusSmall,
                                      ),
                                      border: Border.all(
                                        color: NeoTokens.black,
                                        width: NeoTokens.borderWidthThin,
                                      ),
                                    ),
                                    child: const Icon(
                                      AppIcons.restaurant,
                                      size: AppIcons.sizeToolbar,
                                      color: NeoTokens.black,
                                    ),
                                  ),
                                  const SizedBox(width: NeoTokens.space12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          confirmedItem.foodName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: NeoTokens.textDark,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        NeoBadge(
                                          label:
                                              confirmedItem.source == 'detected'
                                              ? 'Terdeteksi'
                                              : confirmedItem.source ==
                                                    'corrected'
                                              ? 'Dikoreksi'
                                              : 'Manual',
                                          color:
                                              confirmedItem.source == 'detected'
                                              ? NeoBadgeColor.mint
                                              : confirmedItem.source ==
                                                    'corrected'
                                              ? NeoBadgeColor.sky
                                              : NeoBadgeColor.white,
                                          fontSize: 10,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: NeoTokens.space8),
                                  SizedBox(
                                    width: 100,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: NeoTokens.white,
                                        borderRadius: BorderRadius.circular(
                                          NeoTokens.radiusSmall,
                                        ),
                                        border: Border.all(
                                          color: NeoTokens.black,
                                          width: NeoTokens.borderWidthThin,
                                        ),
                                      ),
                                      child: TextFormField(
                                        controller: controller,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        textAlign: TextAlign.end,
                                        onChanged: (val) =>
                                            _onGramsChanged(index, val),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: NeoTokens.textDark,
                                        ),
                                        decoration: const InputDecoration(
                                          suffixText: 'g',
                                          suffixStyle: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: NeoTokens.black,
                                          ),
                                          hintText: '150',
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          focusedErrorBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                        ),
                                        validator: (val) {
                                          if (val == null ||
                                              val.trim().isEmpty) {
                                            return 'Wajib isi';
                                          }
                                          final num = double.tryParse(
                                            val.trim(),
                                          );
                                          if (num == null ||
                                              num <= 0 ||
                                              num > 5000) {
                                            return '1-5000g';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: NeoTokens.space10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _buildPortionChip(
                                    index,
                                    '1/2 Porsi (75g)',
                                    75.0,
                                    currentGrams,
                                  ),
                                  _buildPortionChip(
                                    index,
                                    '1 Porsi (150g)',
                                    150.0,
                                    currentGrams,
                                  ),
                                  _buildPortionChip(
                                    index,
                                    'Porsi Besar (250g)',
                                    250.0,
                                    currentGrams,
                                  ),
                                ],
                              ),
                              const SizedBox(height: NeoTokens.space10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: NeoTokens.surfaceMuted,
                                  borderRadius: BorderRadius.circular(
                                    NeoTokens.radiusSmall,
                                  ),
                                  border: Border.all(
                                    color: NeoTokens.black,
                                    width: NeoTokens.borderWidthThin,
                                  ),
                                ),
                                child: confirmedItem.hasNutritionData
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildMacroItem(
                                            'Kalori',
                                            '${confirmedItem.estimatedCalories.round()} kkal',
                                            NeoTokens.textDark,
                                            isBold: true,
                                          ),
                                          _buildMacroItem(
                                            'Protein',
                                            '${confirmedItem.estimatedProtein.toStringAsFixed(1)}g',
                                            NeoTokens.cobaltBlue,
                                          ),
                                          _buildMacroItem(
                                            'Karbo',
                                            '${confirmedItem.estimatedCarbs.toStringAsFixed(1)}g',
                                            NeoTokens.vividYellow,
                                          ),
                                          _buildMacroItem(
                                            'Lemak',
                                            '${confirmedItem.estimatedFat.toStringAsFixed(1)}g',
                                            NeoTokens.coralRed,
                                          ),
                                        ],
                                      )
                                    : const Center(
                                        child: Text(
                                          'Data gizi dasar belum tersedia untuk item ini',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: NeoTokens.textMuted,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    if (items.isNotEmpty) ...[
                      const SizedBox(height: NeoTokens.space12),
                      NeoCard(
                        backgroundColor: NeoTokens.electricLime,
                        padding: const EdgeInsets.all(NeoTokens.space14),
                        shadowOffset: NeoTokens.shadowOffsetSmall,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  AppIcons.calculate,
                                  size: AppIcons.sizeControl,
                                  color: NeoTokens.black,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Total Estimasi Gizi Menu Ini',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: NeoTokens.black,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSummaryMacro(
                                  'Energi',
                                  '${flow.totalEstimatedCalories.round()}',
                                  'kkal',
                                ),
                                _buildSummaryMacro(
                                  'Protein',
                                  flow.totalEstimatedProtein.toStringAsFixed(1),
                                  'g',
                                ),
                                _buildSummaryMacro(
                                  'Karbo',
                                  flow.totalEstimatedCarbs.toStringAsFixed(1),
                                  'g',
                                ),
                                _buildSummaryMacro(
                                  'Lemak',
                                  flow.totalEstimatedFat.toStringAsFixed(1),
                                  'g',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(NeoTokens.space16),
            decoration: const BoxDecoration(
              color: NeoTokens.warmBackground,
              border: Border(top: BorderSide(color: NeoTokens.black, width: 2)),
            ),
            child: SafeArea(
              child: NeoButton(
                text: 'Simpan & Catat Makanan',
                prefixIcon: AppIcons.checkCircleOutline,
                variant: NeoButtonVariant.primary,
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
