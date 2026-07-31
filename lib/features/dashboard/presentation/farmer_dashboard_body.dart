import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/language/language_cubit.dart';
import '../../../core/role/role_cubit.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../listings/domain/listing.dart';
import '../../listings/presentation/listing_detail_screen.dart';
import '../../listings/presentation/listings_cubit.dart';
import '../../offers/presentation/farmer_offers_cubit.dart';
import '../domain/market_price_model.dart';
import 'farmer_dashboard_cubit.dart';
import 'farmer_dashboard_state.dart';

class FarmerDashboardBody extends StatefulWidget {
  const FarmerDashboardBody({super.key});

  @override
  State<FarmerDashboardBody> createState() => _FarmerDashboardBodyState();
}

class _FarmerDashboardBodyState extends State<FarmerDashboardBody> {
  bool _isFarmer(BuildContext context) {
    final authRole = context.read<AuthCubit>().state.user?.role;
    if (authRole != null && authRole != UserRole.none) {
      return authRole == UserRole.farmer;
    }
    return context.read<RoleCubit>().state == UserRole.farmer;
  }

  @override
  void initState() {
    super.initState();
    context.read<FarmerDashboardCubit>().watchPrices();
    if (!_isFarmer(context)) return;

    final farmerId = context.read<AuthCubit>().state.user?.id;
    if (farmerId != null) {
      context.read<FarmerOffersCubit>().watchForFarmer(farmerId);
      context.read<ListingsCubit>().startWatching();
    }
  }

  void _openListingOffers(
    BuildContext context, {
    required String listingId,
    required Listing? listing,
    required String farmerId,
  }) {
    if (listing != null) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => ListingDetailScreen(
            listing: listing,
            currentUserId: farmerId,
            showOffersOnOpen: true,
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listing details are loading. Try again in a moment.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageCubit>().state;
    final strings = AppStrings(
      language == AppLanguage.kinyarwanda ? 'rw' : 'en',
    );
    final farmerId = context.watch<AuthCubit>().state.user?.id ?? '';
    final isFarmer = _isFarmer(context);

    return BlocConsumer<FarmerDashboardCubit, FarmerDashboardState>(
      listener: (context, state) {
        if (state is FarmerDashboardError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(strings.get('errorGeneric'))));
        }
      },
      builder: (context, state) {
        if (state is FarmerDashboardLoading || state is FarmerDashboardInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FarmerDashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 48),
                const SizedBox(height: 12),
                Text(strings.get('errorGeneric')),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () =>
                      context.read<FarmerDashboardCubit>().watchPrices(),
                  child: Text(strings.get('retry')),
                ),
              ],
            ),
          );
        }

        final prices = (state as FarmerDashboardLoaded).prices;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isFarmer)
              _IncomingOffersSection(
                farmerId: farmerId,
                onListingTap: (listingId, listing) => _openListingOffers(
                  context,
                  listingId: listingId,
                  listing: listing,
                  farmerId: farmerId,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                strings.get('marketPrices'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: prices.isEmpty
                  ? Center(child: Text(strings.get('noPrices')))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth < 600
                            ? 1
                            : 2;
                        return GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                mainAxisExtent: 110,
                              ),
                          itemCount: prices.length,
                          itemBuilder: (context, index) => _PriceCard(
                            price: prices[index],
                            strings: strings,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _IncomingOffersSection extends StatelessWidget {
  const _IncomingOffersSection({
    required this.farmerId,
    required this.onListingTap,
  });

  final String farmerId;
  final void Function(String listingId, Listing? listing) onListingTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FarmerOffersCubit, FarmerOffersState>(
      builder: (context, offersState) {
        final pendingByListing = offersState.pendingByListing;
        if (pendingByListing.isEmpty) {
          return const SizedBox.shrink();
        }

        final listings = context.watch<ListingsCubit>().state.listings;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Incoming Offers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...pendingByListing.entries.map((entry) {
                final listingId = entry.key;
                final offers = entry.value;
                final listingMatches =
                    listings.where((item) => item.id == listingId);
                final listing =
                    listingMatches.isEmpty ? null : listingMatches.first;
                final cropName =
                    listing?.cropType ?? offers.first.cropType;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onListingTap(listingId, listing),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.badgeOffersBg,
                            child: Icon(
                              Icons.local_offer,
                              color: AppColors.badgeOffersText,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cropName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${offers.length} pending '
                                  '${offers.length == 1 ? 'offer' : 'offers'}',
                                  style: const TextStyle(
                                    color: AppColors.subtitleGrey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.subtitleGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.price, required this.strings});

  final MarketPrice price;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.grass, color: scheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    price.cropType,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${price.minPrice.toStringAsFixed(0)} – '
                    '${price.maxPrice.toStringAsFixed(0)} RWF '
                    '${strings.get('perKg')}',
                    style: TextStyle(fontSize: 13, color: scheme.outline),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${price.averagePrice.toStringAsFixed(0)} RWF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
                Text(
                  '${price.listingCount} ${strings.get('listings')}',
                  style: TextStyle(fontSize: 12, color: scheme.outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
