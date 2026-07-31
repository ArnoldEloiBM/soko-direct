import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/listing_card.dart';
import '../../../offers/presentation/pages/make_offer_page.dart';

//using fake listings below for now, swap this out once firebase is ready
class BuyerDashboardPage extends StatefulWidget {
  const BuyerDashboardPage({super.key});

  @override
  State<BuyerDashboardPage> createState() => _BuyerDashboardPageState();
}

class _BuyerDashboardPageState extends State<BuyerDashboardPage> {
  String searchText = '';
  String? cropFilter;

  //fake listings just so we can see the screen working
  final fakeListings = [
    {
      'crop': 'Tomatoes',
      'farmer': 'Uwimana Chantal',
      'district': 'Musanze',
      'price': 480.0,
      'rating': 4.8,
      'verified': true,
    },
    {
      'crop': 'Onions',
      'farmer': 'Nkurunziza Jean',
      'district': 'Huye',
      'price': 350.0,
      'rating': 4.2,
      'verified': false,
    },
    {
      'crop': 'Green Peppers',
      'farmer': 'Mukamana Alice',
      'district': 'Bugesera',
      'price': 520.0,
      'rating': 4.9,
      'verified': true,
    },
  ];

  List<Map<String, dynamic>> get visibleListings {
    return fakeListings.where((l) {
      final matchesSearch =
          searchText.isEmpty ||
          l['crop'].toString().toLowerCase().contains(searchText.toLowerCase());
      final matchesCrop = cropFilter == null || l['crop'] == cropFilter;
      return matchesSearch && matchesCrop;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Produce'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchFilterBar(
              onChanged: (query, crop) {
                setState(() {
                  searchText = query;
                  cropFilter = crop;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: visibleListings.isEmpty
                  ? const Center(child: Text('No produce matches your search.'))
                  : GridView.builder(
                      itemCount: visibleListings.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                      itemBuilder: (context, i) {
                        final l = visibleListings[i];
                        return ListingCard(
                          cropName: l['crop'] as String,
                          farmerName: l['farmer'] as String,
                          district: l['district'] as String,
                          pricePerKg: l['price'] as double,
                          photoUrl: '',
                          rating: l['rating'] as double,
                          verified: l['verified'] as bool,
                          onTap: () {
                            // TEMP: goes straight to Make Offer, skipping Listing
                            // Detail for now since that screen isn't built yet.
                            // Once it exists, tap should open that instead.
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MakeOfferPage(
                                  cropName: l['crop'] as String,
                                  marketPrice: l['price'] as double,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
