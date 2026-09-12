import 'package:flutter/material.dart';
import '../theme/app_radius.dart';
import '../theme/app_colors.dart';

/// Champ de recherche DS — spec `FLUTTER_PROTOTYPE_SPEC.md` §5.11.
///
/// Hauteur 56, radius 28, fond white/10, loupe intégrée à gauche,
/// bordure white/6 → primary/50 au focus.
class AppSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;

  const AppSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Rechercher…',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 18, right: 12),
          child: Icon(
            Icons.search,
            size: 20,
            color: AppColors.textMuted,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 50),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        filled: true,
        fillColor: AppColors.glassSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: Color(0x0FFFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(color: Color(0x0FFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: const BorderSide(
            color: AppColors.primaryBorder,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}