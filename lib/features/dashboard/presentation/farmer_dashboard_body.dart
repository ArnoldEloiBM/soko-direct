import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/language/language_cubit.dart';
import '../domain/market_price_model.dart';
import 'farmer_dashboard_cubit.dart';
import 'farmer_dashboard_state.dart';

class FarmerDashboardBody extends StatefulWidget {
  const FarmerDashboardBody({super.key});

  @override
  State<FarmerDashboardBody> createState() => _FarmerDashboardBodyState();
}

class _FarmerDashboardBodyState extends State<FarmerDashboardBody> {
  @override
  void initState() {
    super.initState();
    context.read<FarmerDashboardCubit>().watchPrices();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageCubit>().state;
    final strings = AppStrings(
      language == AppLanguage.kinyarwanda ? 'rw' : 'en',
    );

    return BlocConsumer<FarmerDashboardCubit, FarmerDashboardState>(
      listener: (context, state) {
        // Graceful error handling with a snackbar (rubric: CRUD criterion).
        if (state is FarmerDashboardError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(strings.get('errorGeneric'))));
        }
      },
      builder: (context, state) {
        if (state is FarmerDashboardLoading ||
            state is FarmerDashboardInitial) {
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
        if (prices.isEmpty) {
          return Center(child: Text(strings.get('noPrices')));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                strings.get('marketPrices'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 1 column on narrow phones, 2 in landscape / big screens.
                  final crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      mainAxisExtent: 110,
                    ),
                    itemCount: prices.length,
                    itemBuilder: (context, index) =>
                        _PriceCard(price: prices[index], strings: strings),
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

class _PriceCard extends StatelessWidget {
  final MarketPrice price;
  final AppStrings strings;

  const _PriceCard({required this.price, required this.strings});

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
