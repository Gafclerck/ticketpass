import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ticketpass/core/routing/app_routes.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/core/theme/app_typography.dart';
import 'package:ticketpass/core/widgets/app_button.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';

import '../providers/auth_providers.dart';

/// UC14 — Connexion.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(signInProvider).call(
            _emailController.text.trim(),
            _passwordController.text,
          );
      // Pas de navigation manuelle ici : la garde de route (app_router.dart)
      // redirige automatiquement vers /home dès qu'elle reçoit le nouvel
      // état d'auth. Un context.go() ici entrerait en course avec elle.
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connexion impossible : $error')),
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
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.confirmation_number,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Bon retour\nparmi nous !',
                style: TextStyle(
                  fontFamily: AppTypography.ui,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  height: 1.25,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Connectez-vous à votre compte.',
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
                        if (value == null || value.isEmpty) {
                          return 'Le mot de passe est obligatoire.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Réinitialisation du mot de passe — bientôt disponible.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Se connecter',
                fullWidth: true,
                onPressed: _isLoading ? null : _signIn,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pas encore de compte ? ',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.register),
                    child: const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
