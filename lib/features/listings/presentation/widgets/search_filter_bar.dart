import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/listing_options.dart';

//search box + crop filter chips on top of the buyer dashboard
//sends the search text and picked crop back up to the dashboard screen
class SearchFilterBar extends StatefulWidget {
  final Function(String query, String? crop) onChanged;

  const SearchFilterBar({super.key, required this.onChanged});

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final TextEditingController searchCtrl = TextEditingController();
  String? pickedCrop;

  // Matches ListingOptions.cropTypes so filtering actually works against
  // real listings (this used to list crops that don't exist in the
  // listings feature at all, like Potatoes/Cabbage).
  final crops = ['All', ...ListingOptions.cropTypes];

  void updateParent() {
    widget.onChanged(searchCtrl.text, pickedCrop == 'All' ? null : pickedCrop);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchCtrl,
          onChanged: (_) => updateParent(),
          decoration: InputDecoration(
            hintText: 'Search produce...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: AppColors.sandBeige,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: crops.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final crop = crops[i];
              final selected =
                  pickedCrop == crop || (pickedCrop == null && crop == 'All');
              return ChoiceChip(
                label: Text(crop),
                selected: selected,
                selectedColor: AppColors.primaryGreen,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontSize: 12,
                ),
                onSelected: (_) {
                  setState(() => pickedCrop = crop);
                  updateParent();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
