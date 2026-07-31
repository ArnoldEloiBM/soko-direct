import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../offer_cubit.dart';
import '../offer_state.dart';
import '../../domain/offer_total.dart';

// make offer / negotiate screen
// TEMP: no auth yet from samuel and no real listing from arnold,
// so using fake ids for now just so we can test writing to firebase.
// once auth + listings are ready, swap these 3 lines for the real values.
const _tempListingId = 'demo-listing-01';
const _tempBuyerId = 'demo-buyer-01';
const _tempFarmerId = 'demo-farmer-01';

class MakeOfferPage extends StatefulWidget {
  final String cropName;
  final double marketPrice;

  const MakeOfferPage({super.key, required this.cropName, required this.marketPrice});

  @override
  State<MakeOfferPage> createState() => _MakeOfferPageState();
}

class _MakeOfferPageState extends State<MakeOfferPage> {
  late double myPrice;
  int qty = 10;

  @override
  void initState() {
    super.initState();
    myPrice = widget.marketPrice;
  }

  void changePrice(double amount) {
    setState(() => myPrice = (myPrice + amount).clamp(0, 999999));
  }

  void changeQty(int amount) {
    setState(() => qty = (qty + amount).clamp(1, 9999));
  }

  void sendOffer() {
    context.read<OfferCubit>().submitOffer(
          listingId: _tempListingId,
          buyerId: _tempBuyerId,
          farmerId: _tempFarmerId,
          pricePerKg: myPrice,
          quantityKg: qty,
        );
  }

  @override
  Widget build(BuildContext context) {
    final total = calculateOfferTotal(myPrice, qty);

    return Scaffold(
      appBar: AppBar(title: Text('Offer for ${widget.cropName}'), backgroundColor: AppColors.primaryGreen),
      body: BlocListener<OfferCubit, OfferState>(
        listener: (context, state) {
          if (state.submitStatus == OfferSubmitStatus.success) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Offer Sent'),
                content: Text('Offer of ${myPrice.toStringAsFixed(0)} RWF/kg for $qty kg sent.'),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
              ),
            );
          } else if (state.submitStatus == OfferSubmitStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Something went wrong.')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Market price: ${widget.marketPrice.toStringAsFixed(0)} RWF/kg', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              const Text('Your offer (RWF/kg)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              PriceStepper(value: '${myPrice.toStringAsFixed(0)} RWF', onMinus: () => changePrice(-10), onPlus: () => changePrice(10)),
              const SizedBox(height: 20),
              const Text('Quantity (kg)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              PriceStepper(value: '$qty kg', onMinus: () => changeQty(-1), onPlus: () => changeQty(1)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.sandBeige, borderRadius: BorderRadius.circular(10)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${total.toStringAsFixed(0)} RWF',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 16)),
                  ],
                ),
              ),
              const Spacer(),
              BlocBuilder<OfferCubit, OfferState>(
                builder: (context, state) {
                  final isLoading = state.submitStatus == OfferSubmitStatus.submitting;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
                    onPressed: isLoading ? null : sendOffer,
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Send Offer', style: TextStyle(color: Colors.white, fontSize: 16)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// used this for both price and qty rows so i'm not repeating the same layout twice
class PriceStepper extends StatelessWidget {
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const PriceStepper({super.key, required this.value, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: onMinus, icon: const Icon(Icons.remove_circle_outline), color: AppColors.earthBrown),
        Text(value, style: const TextStyle(fontSize: 16)),
        IconButton(onPressed: onPlus, icon: const Icon(Icons.add_circle_outline), color: AppColors.primaryGreen),
      ],
    );
  }
}