import 'package:flutter/material.dart';
import 'package:oopsieeats/core/neo_tokens.dart';
import 'package:oopsieeats/features/profile/widgets/unified_biodata_form.dart';
import 'package:oopsieeats/shared/neo/neo.dart';

/// Screen for managing user biodata with full CRUD, identical styling, and
/// shared components with the onboarding screen.
///
/// Features:
/// - Reuses [UnifiedBiodataForm] in [BiodataFormMode.edit] mode.
/// - Pre-filled with user's actual stored metrics from Firestore.
/// - Identical Neo-Brutalism header, fields, buttons, and validation.
/// - Supports updating and deleting existing physical biodata.
class BiodataScreen extends StatelessWidget {
  const BiodataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: NeoTokens.warmBackground,
      appBar: AppBar(
        backgroundColor: NeoTokens.warmBackground,
        elevation: 0,
        leading: NeoBackButton.leading(context),
        title: const Text(
          'Kelola Biodata',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: NeoTokens.black,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(NeoTokens.borderWidth),
          child: Container(
            color: NeoTokens.black,
            height: NeoTokens.borderWidth,
          ),
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          NeoTokens.space20,
          NeoTokens.space20,
          NeoTokens.space20,
          NeoTokens.space32 + bottomInset,
        ),
        child: UnifiedBiodataForm(
          mode: BiodataFormMode.edit,
          onSavedSuccessfully: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
    );
  }
}
