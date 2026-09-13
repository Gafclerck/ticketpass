import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:ticketpass/core/security/ticket_signature_service.dart';
import 'package:ticketpass/core/theme/app_colors.dart';
import 'package:ticketpass/core/theme/app_radius.dart';
import 'package:ticketpass/core/theme/app_spacing.dart';
import 'package:ticketpass/core/theme/app_theme.dart';
import 'package:ticketpass/core/widgets/app_button.dart';
import 'package:ticketpass/core/widgets/glass_card.dart';
import 'package:ticketpass/core/widgets/page_header.dart';
import 'package:ticketpass/core/widgets/pressable_scale.dart';
import 'package:ticketpass/features/auth/domain/entities/role.dart';
import 'package:ticketpass/features/auth/presentation/providers/current_user_provider.dart';
import 'package:ticketpass/features/event/presentation/providers/event_providers.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket.dart';
import 'package:ticketpass/features/ticket/domain/entities/ticket_status.dart';
import 'package:ticketpass/features/ticket/presentation/providers/ticket_providers.dart';
import 'package:ticketpass/features/ticket/presentation/widgets/ticket_status_badge.dart';

import '../providers/scan_providers.dart';

/// UC10/UC11 — Scanner un billet puis valider l'entrée.
///
/// Route plein-écran (cache la barre de navigation), réservée aux
/// organisateurs et contrôleurs de l'événement. La caméra lit le QR du billet
/// (`TicketSignatureService.buildQrPayload`), puis la vérification offline
/// UC10 précède la transition `VALID → USED` (UC11).
///
/// Un repli « Saisie manuelle » reste disponible (caméra indisponible, tests).
class ScanEventTicketsPage extends ConsumerStatefulWidget {
  final String eventId;

  const ScanEventTicketsPage({super.key, required this.eventId});

  @override
  ConsumerState<ScanEventTicketsPage> createState() =>
      _ScanEventTicketsPageState();
}

class _ScanEventTicketsPageState extends ConsumerState<ScanEventTicketsPage> {
  final _payloadController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  Ticket? _checkedTicket;
  String? _errorMessage;
  String _lastPayload = '';
  bool _useCamera = true;
  bool _manualMode = false;
  bool _isChecking = false;
  bool _isValidating = false;

  @override
  void initState() {
    super.initState();
    _useCamera = ref.read(scanUseCameraProvider);
  }

  @override
  void dispose() {
    _payloadController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final raw = barcodes.first.rawValue;
    if (raw == null || raw == _lastPayload) return;

    _lastPayload = raw;
    _processPayload(raw);
  }

  void _setMode({required bool manual}) {
    setState(() => _manualMode = manual);

    if (!_useCamera) return;

    final action = manual
        ? _scannerController.stop()
        : _scannerController.start();

    action.ignore();
  }

  Future<void> _processPayload(String payload) async {
    setState(() {
      _checkedTicket = null;
      _errorMessage = null;
    });

    if (!TicketSignatureService.verifyQrPayload(payload)) {
      setState(() {
        _errorMessage = 'QR illisible ou signature invalide.';
      });
      return;
    }

    final parts = payload.split('|');
    final ticketId = parts[0];
    final payloadEventId = parts[1];

    if (payloadEventId != widget.eventId) {
      setState(() {
        _errorMessage = 'Ce billet ne correspond pas à cet événement.';
      });
      return;
    }

    setState(() => _isChecking = true);

    try {
      final ticket = await ref.read(getTicketProvider).call(ticketId);
      if (!mounted) return;
      setState(() => _checkedTicket = ticket);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Billet introuvable.';
      });
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _checkManual() => _processPayload(_payloadController.text.trim());

  Future<void> _validate(Ticket ticket) async {
    setState(() => _isValidating = true);

    try {
      final used = await ref.read(validateTicketProvider).call(ticket.id);
      if (!mounted) return;

      ref.invalidate(myTicketsProvider(used.userId));

      setState(() => _checkedTicket = used);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Billet validé — entrée autorisée.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = '$error';
      });
    } finally {
      if (mounted) setState(() => _isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider).id;
    final rolesAsync = ref.watch(eventRolesProvider(widget.eventId));
    final eventAsync = ref.watch(eventProvider(widget.eventId));

    final roles = rolesAsync.value ?? const [];
    final canScan = roles.any(
      (role) =>
          role.userId == userId &&
          (role.role == Role.organiser || role.role == Role.controller),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: !canScan
          ? _AccessDenied(eventTitle: eventAsync.value?.title)
          : SafeArea(
              bottom: false,
              child: ListView(
                padding: AppTheme.pagePadding(
                  bottom: AppSpacing.bottomClearanceNoNav,
                ),
                children: [
                  PageHeader(
                    title: 'Scanner',
                    subtitle: eventAsync.value?.title,
                    showBack: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Scannez le QR code présenté par le porteur pour vérifier '
                    'puis valider son billet.',
                    style: TextStyle(
                      height: 1.4,
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_useCamera && !_manualMode) ...[
                    _CameraView(
                      controller: _scannerController,
                      onDetect: _onDetect,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ModeToggle(
                      label: 'Saisie manuelle',
                      icon: Icons.keyboard_outlined,
                      onTap: () => _setMode(manual: true),
                    ),
                  ] else ...[
                    TextField(
                      controller: _payloadController,
                      maxLines: 2,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Contenu du QR',
                        hintText: 'ticketId|eventId|signature',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Vérifier',
                      fullWidth: true,
                      icon: Icons.qr_code_scanner,
                      onPressed: _isChecking || _isValidating
                          ? null
                          : _checkManual,
                    ),
                    if (_useCamera) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _ModeToggle(
                        label: 'Activer la caméra',
                        icon: Icons.qr_code_scanner,
                        onTap: () => _setMode(manual: false),
                      ),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  if (_errorMessage != null)
                    _MessageCard(
                      message: _errorMessage!,
                      isError: true,
                    ),
                  if (_checkedTicket != null) ...[
                    if (_errorMessage != null)
                      const SizedBox(height: AppSpacing.sm),
                    _CheckedTicketCard(
                      ticket: _checkedTicket!,
                      eventId: widget.eventId,
                      isValidating: _isValidating,
                      onValidate: () => _validate(_checkedTicket!),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _CameraView extends StatelessWidget {
  final MobileScannerController controller;
  final ValueChanged<BarcodeCapture> onDetect;

  const _CameraView({required this.controller, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.box),
      child: SizedBox(
        height: 360,
        child: MobileScanner(
          controller: controller,
          onDetect: onDetect,
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeToggle({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.97,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.glassSubtle,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _CheckedTicketCard extends StatelessWidget {
  final Ticket ticket;
  final String eventId;
  final bool isValidating;
  final VoidCallback onValidate;

  const _CheckedTicketCard({
    required this.ticket,
    required this.eventId,
    required this.isValidating,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    final matchesEvent = ticket.eventId == eventId;
    final canValidate =
        matchesEvent && ticket.status == TicketStatus.valid && !isValidating;

    return GlassCard(
      mode: GlassCardMode.defaultMode,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Billet #${ticket.id.split('-').last.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TicketStatusBadge(status: ticket.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          SelectableText(
            ticket.uniqueCode,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (ticket.userId.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Détenteur : ${ticket.userId}',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ],
          if (!matchesEvent) ...[
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Ce billet appartient à un autre événement.',
              style: TextStyle(color: AppColors.errorText, fontSize: 13),
            ),
          ] else if (ticket.status == TicketStatus.valid)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: AppButton(
                label: 'Valider l’entrée',
                fullWidth: true,
                icon: Icons.verified_outlined,
                onPressed: canValidate ? onValidate : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageCard({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.errorText : AppColors.successText;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(AppRadius.box),
        border: Border.all(
          color: isError ? AppColors.errorBorder : AppColors.glassBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            size: 20,
            color: color,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message, style: TextStyle(color: color, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _AccessDenied extends StatelessWidget {
  final String? eventTitle;

  const _AccessDenied({this.eventTitle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: AppTheme.pagePadding(bottom: AppSpacing.bottomClearanceNoNav),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHeader(
              title: 'Scanner',
              subtitle: eventTitle,
              showBack: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            const _MessageCard(
              message:
                  'Accès réservé aux organisateurs et contrôleurs de '
                  'l’événement.',
              isError: true,
            ),
          ],
        ),
      ),
    );
  }
}