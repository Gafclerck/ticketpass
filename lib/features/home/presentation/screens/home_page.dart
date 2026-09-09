import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ticketpass/core/theme/app_colors.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Text(
          'Home',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
