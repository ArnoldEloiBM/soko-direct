import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/offer.dart';
import '../../domain/offer_total.dart';
import '../offer_cubit.dart';
import '../offer_state.dart';

/// Live list of offers on a listing, with accept/decline for the farmer.
class ListingOffersPanel extends StatefulWidget {
  const ListingOffersPanel({
    super.key,
    required this.listingId,
    required this.showPendingOnly,
  });

  final String listingId;
  final bool showPendingOnly;

  @override
  State<ListingOffersPanel> createState() => _ListingOffersPanelState();
}

class _ListingOffersPanelState extends State<ListingOffersPanel> {
  @override
  void initState() {
    super.initState();
    context.read<OfferCubit>().watchOffersForListing(widget.listingId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OfferCubit, OfferState>(
      listenWhen: (previous, current) =>
          current.actionMessage != null &&
          current.actionMessage != previous.actionMessage,
      listener: (context, state) {
        if (state.actionMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.actionMessage!),
                backgroundColor: AppColors.primaryGreen,
              ),
            );
          context.read<OfferCubit>().clearActionMessage();
        }
      },
      builder: (context, state) {
        final offers = widget.showPendingOnly
            ? state.pendingOffers
            : state.offers;

        if (offers.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              widget.showPendingOnly
                  ? 'No pending offers yet.'
                  : 'No offers on this listing yet.',
              style: const TextStyle(color: AppColors.subtitleGrey),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: offers
              .map(
                (offer) => _OfferTile(
                  offer: offer,
                  isUpdating:
                      state.actionStatus == OfferActionStatus.updating,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer, required this.isUpdating});

  final Offer offer;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final total = calculateOfferTotal(offer.pricePerKg, offer.quantityKg);
    final canRespond = offer.isPending;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${offer.pricePerKg.toStringAsFixed(0)} RWF/kg · '
                    '${offer.quantityKg} kg',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                _StatusChip(status: offer.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Total: ${total.toStringAsFixed(0)} RWF',
              style: const TextStyle(color: AppColors.subtitleGrey),
            ),
            if (canRespond) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isUpdating
                          ? null
                          : () => context.read<OfferCubit>().respondToOffer(
                              offerId: offer.id,
                              accept: false,
                            ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade700,
                        side: BorderSide(color: Colors.red.shade300),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: isUpdating
                          ? null
                          : () => context.read<OfferCubit>().respondToOffer(
                              offerId: offer.id,
                              accept: true,
                            ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      'accepted' => ('Accepted', AppColors.badgeActiveBg, AppColors.badgeActiveText),
      'rejected' => ('Declined', AppColors.badgeSoldBg, AppColors.badgeSoldText),
      _ => ('Pending', AppColors.badgeOffersBg, AppColors.badgeOffersText),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
