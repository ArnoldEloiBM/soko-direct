import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import '../../domain/entities/app_transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currentUserId,
  });

  final AppTransaction transaction;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final isBuyer = transaction.buyerId == currentUserId;
    final dateLabel = intl.DateFormat.yMMMd().add_jm().format(
      transaction.createdAt,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            isBuyer ? Icons.shopping_bag_outlined : Icons.agriculture_outlined,
          ),
        ),
        title: Text(
          '${isBuyer ? 'Bought' : 'Sold'} ${transaction.cropType.isEmpty ? 'crop' : transaction.cropType}',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateLabel),
            const SizedBox(height: 4),
            Row(
              children: [
                _StatusChip(status: transaction.escrowStatus),
                if (transaction.deliveryConfirmed) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.local_shipping_outlined, size: 16),
                  const SizedBox(width: 2),
                  const Text('Delivered', style: TextStyle(fontSize: 12)),
                ],
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: Text(
          'RWF ${transaction.amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final EscrowStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      EscrowStatus.pending => ('Pending', Colors.orange),
      EscrowStatus.held => ('Payment held', Colors.blue),
      EscrowStatus.released => ('Payment released', Colors.green),
      EscrowStatus.cancelled => ('Cancelled', Colors.red),
    };
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withValues(alpha: 0.15),
      labelStyle: TextStyle(color: color),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
