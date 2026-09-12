import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Avatar utilisateur — spec `FLUTTER_PROTOTYPE_SPEC.md` §5.13.
///
/// Image de profil (couverture complète) avec fallback initiales
/// (fond primary/30, lettres blanches `size * 0.36`).
class UserAvatar extends StatelessWidget {
  final String? src;
  final String? name;
  final double size;

  const UserAvatar({super.key, this.src, this.name, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final src = this.src;
    if (src != null && src.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          src,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
        ),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    final initials = (name == null || name!.isEmpty)
        ? '?'
        : _initials(name!);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.avatarBackground,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}