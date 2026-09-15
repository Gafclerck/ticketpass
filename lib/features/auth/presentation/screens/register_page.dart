import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/core/theme/app_typography.dart';
import 'package:ticketpass/core/widgets/app_button.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';

import '../providers/auth_providers.dart';

/// UC14 — Inscription.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(signUpProvider).call(
            _emailController.text.trim(),
            _passwordController.text,
            _fullNameController.text.trim(),
          );
      // Pas de navigation manuelle ici : la garde de route (app_router.dart)
      // redirige automatiquement vers /home dès qu'elle reçoit le nouvel
      // état d'auth. Un context.go() ici entrerait en course avec elle.
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inscription impossible : $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppTheme.pagePadding(bottom: AppSpacing.xxl),
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left, size: 20, color: AppColors.textSecondary),
                    SizedBox(width: 4),
                    Text('Retour', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Créer un compte',
                style: TextStyle(
                  fontFamily: AppTypography.ui,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Rejoignez la communauté TicketPass.',
                style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              GlassCard(
                mode: GlassCardMode.elevated,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Nom complet'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom est obligatoire.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'L\'email est obligatoire.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Minimum 6 caractères.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'S\'inscrire',
                fullWidth: true,
                onPressed: _isLoading ? null : _signUp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
