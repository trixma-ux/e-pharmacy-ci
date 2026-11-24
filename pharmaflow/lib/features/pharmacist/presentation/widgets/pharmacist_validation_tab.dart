import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/models/user_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/pharmacist_validation_repository.dart';

/// Onglet « Validations » du tableau de bord : liste des pharmaciens en
/// attente et bouton « Valider ». Réservé à un pharmacien validé ou un admin.
class PharmacistValidationTab extends ConsumerWidget {
  const PharmacistValidationTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authControllerProvider).valueOrNull;
    if (me == null || !me.isStaff) {
      return const _Info(
        icon: Icons.lock_outline_rounded,
        text: 'Seuls les pharmaciens validés et les administrateurs peuvent valider des comptes.',
      );
    }
    final pendingAsync = ref.watch(pendingPharmacistsProvider);
    return pendingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _Info(
        icon: Icons.error_outline_rounded,
        text: 'Impossible de charger les comptes en attente.',
      ),
      data: (all) {
        final list = all.where((u) => u.id != me.id).toList();
        if (list.isEmpty) {
          return const _Info(
            icon: Icons.verified_user_outlined,
            text: 'Aucun pharmacien en attente de validation.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _PendingCard(user: list[i], validatorUid: me.id),
        );
      },
    );
  }
}

class _PendingCard extends ConsumerStatefulWidget {
  const _PendingCard({required this.user, required this.validatorUid});
  final UserModel user;
  final String validatorUid;

  @override
  ConsumerState<_PendingCard> createState() => _PendingCardState();
}

class _PendingCardState extends ConsumerState<_PendingCard> {
  bool _busy = false;

  Future<void> _approve() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Valider ce pharmacien ?'),
        content: Text('${widget.user.name} pourra accéder au tableau de bord et gérer les commandes.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Valider')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(pharmacistValidationRepositoryProvider).approve(
            pharmacistUid: widget.user.id,
            validatorUid: widget.validatorUid,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${widget.user.name} a été validé.'),
        backgroundColor: AppColors.success,
      ));
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Validation refusée. Réessayez ou contactez un administrateur.'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    final date = DateFormat('dd/MM/yyyy HH:mm').format(u.createdAt);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(u.name.isNotEmpty ? u.name[0].toUpperCase() : 'P',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(u.recoveryEmail.isNotEmpty ? u.recoveryEmail : u.email,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                Text('Inscrit le $date',
                    style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _busy ? null : _approve,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _busy
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Valider'),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textSecondaryLight),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondaryLight)),
          ],
        ),
      ),
    );
  }
}
