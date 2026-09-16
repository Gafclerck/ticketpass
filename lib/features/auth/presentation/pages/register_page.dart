import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ticketpass/core/routing/app_routes.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_radius.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_typography.dart';
import 'package:ticketpass/core/widgets/app_button.dart';
import 'package:ticketpass/core/widgets/app_top_bar.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';
import 'package:ticketpass/core/widgets/pressable_scale.dart';
import 'package:ticketpass/features/auth/domain/errors/auth_exception.dart';
import 'package:ticketpass/features/auth/presentation/providers/auth_providers.dart';
import 'package:ticketpass/features/auth/presentation/providers/avatar_providers.dart';
import 'package:ticketpass/features/auth/presentation/providers/current_user_provider.dart';

/// Écran d'inscription (nom + email + mot de passe + confirmer + avatar
/// optionnel) — route racine `/register`, hors barre de navigation.
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
  final _confirmController = TextEditingController();
  Uint8List? _avatarBytes;
  bool _isSubmitting = false;
  bool _isPicking = false;
  String? _errorMessage;

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      final file = await ref.read(imagePickerProvider).pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        if (!mounted) return;
        setState(() => _avatarBytes = bytes);
      }
    } catch (_) {
      // Sélecteur indisponible : l'avatar reste optionnel, on ne bloque pas.
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final controller = ref.read(authControllerProvider.notifier);
      await controller.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
      );

      final bytes = _avatarBytes;
      if (bytes != null && bytes.isNotEmpty) {
        final user = ref.read(currentUserProvider);
        if (user != null) {
          final url = await ref
              .read(profileImageDatasourceProvider)
              .uploadProfileImage(userId: user.id, bytes: bytes);
          await controller.updateProfile(profileUrl: url);
        }
      }
      // Succès : le redirect du routeur gère la navigation.
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Une erreur est survenue. Réessayez.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const AppSafeTopBand(),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.pageTop,
                  AppSpacing.pageHorizontal,
                  AppSpacing.bottomClearanceNoNav +
                      MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  const SizedBox(height: AppSpacing.lg * 2),
                  Text(
                    'Créer un compte',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: AppTypography.display,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Rejoignez TicketPass en quelques secondes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (_errorMessage != null) ...[
                    _RegisterErrorBanner(message: _errorMessage!),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Center(
                    child: PressableScale(
                      onTap: _isSubmitting ? null : _pickAvatar,
                      pressedScale: 0.95,
                      child: _AvatarPreview(bytes: _avatarBytes),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _fullNameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Le nom complet est obligatoire.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';
                      if (email.isEmpty) {
                        return 'L’email est obligatoire.';
                      }
                      if (!_emailRegex.hasMatch(email)) {
                        return 'Adresse email invalide.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Mot de passe',
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Le mot de passe fait 6 caractères minimum.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: _isSubmitting ? 'Création…' : 'Créer mon compte',
                    fullWidth: true,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    child: PressableScale(
                      onTap: _isSubmitting ? null : () => context.go(AppRoutes.login),
                      pressedScale: 0.97,
                      child: const Text(
                        'Déjà un compte ? Se connecter',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  final Uint8List? bytes;

  const _AvatarPreview({this.bytes});

  @override
  Widget build(BuildContext context) {
    final image = bytes;
    return GlassCard(
      mode: GlassCardMode.elevated,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: ClipOval(
        child: image != null
            ? Image.memory(
                image,
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              )
            : const SizedBox(
                width: 96,
                height: 96,
                child: Icon(
                  Icons.add_a_photo_outlined,
                  size: 32,
                  color: AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}

class _RegisterErrorBanner extends StatelessWidget {
  final String message;

  const _RegisterErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.box),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorText, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.errorText, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}