import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'rating_cubit.dart';
import 'rating_state.dart';

/// Screen shown after a transaction completes (submit a rating) and
/// also reused on a user's profile (view their ratings).
class RatingScreen extends StatefulWidget {
  final String transactionId;
  final String raterId;
  final String rateeId;
  final String rateeName;

  const RatingScreen({
    super.key,
    required this.transactionId,
    required this.raterId,
    required this.rateeId,
    required this.rateeName,
  });

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _selectedStars = 0;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RatingCubit>().watchRatingsForUser(widget.rateeId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Rate ${widget.rateeName}')),
      body: BlocConsumer<RatingCubit, RatingState>(
        listener: (context, state) {
          if (state.submitStatus == RatingSubmitStatus.success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Rating submitted')));
            setState(() {
              _selectedStars = 0;
              _commentController.clear();
            });
          } else if (state.submitStatus == RatingSubmitStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Leave a rating',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final starIndex = i + 1;
                    return IconButton(
                      icon: Icon(
                        starIndex <= _selectedStars
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () =>
                          setState(() => _selectedStars = starIndex),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed:
                      _selectedStars == 0 ||
                          state.submitStatus == RatingSubmitStatus.submitting
                      ? null
                      : () => context.read<RatingCubit>().submitRating(
                          transactionId: widget.transactionId,
                          raterId: widget.raterId,
                          rateeId: widget.rateeId,
                          stars: _selectedStars,
                          comment: _commentController.text,
                        ),
                  child: state.submitStatus == RatingSubmitStatus.submitting
                      ? const CircularProgressIndicator()
                      : const Text('Submit Rating'),
                ),
                const Divider(height: 32),
                Row(
                  children: [
                    Text(
                      'Past Ratings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (state.ratings.isNotEmpty)
                      Text(
                        '${state.averageStars.toStringAsFixed(1)} ★ (${state.ratings.length})',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (state.ratings.isEmpty)
                  const Text('No ratings yet.')
                else
                  ...state.ratings.map(
                    (r) => Card(
                      child: ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            r.stars,
                            (_) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ),
                        ),
                        title: Text(
                          r.comment.isEmpty ? '(no comment)' : r.comment,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
