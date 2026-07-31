import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../domain/listing.dart';
import 'listing_card.dart';
import 'listing_detail_screen.dart';
import 'listing_form_screen.dart';
import 'listings_cubit.dart';
import 'listings_state.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ListingsCubit>().startWatching();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ListingsCubit, ListingsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        final message = state.errorMessage ?? state.successMessage;
        if (message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: state.errorMessage != null
                    ? Colors.red.shade700
                    : AppColors.primaryGreen,
              ),
            );
          context.read<ListingsCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildBody(context, state)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OutlinedButton.icon(
                onPressed: state.isBusy ? null : () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('New Listing'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ListingsState state) {
    if (state.isLoading && state.listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.listings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No listings yet.\nTap "+ New Listing" to sell your produce.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.subtitleGrey),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: state.listings.length,
      itemBuilder: (context, index) {
        final listing = state.listings[index];
        return ListingCard(
          listing: listing,
          onTap: () => _openDetail(context, listing),
          onDelete: () => _confirmDelete(context, listing),
        );
      },
    );
  }

  Future<void> _openDetail(BuildContext context, Listing listing) async {
    final currentUserId = context.read<AuthCubit>().state.user?.id ?? '';
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ListingDetailScreen(
          listing: listing,
          currentUserId: currentUserId,
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {Listing? listing}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ListingFormScreen(listing: listing),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Listing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete listing?'),
        content: Text(
          'Remove ${listing.cropType} from your listings? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ListingsCubit>().deleteListing(listing.id);
    }
  }
}
