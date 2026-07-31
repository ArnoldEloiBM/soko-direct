import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../domain/listing.dart';
import '../domain/listing_input.dart';
import '../domain/listing_options.dart';
import 'listing_photo.dart';
import 'listings_cubit.dart';
import 'listings_state.dart';

class ListingFormScreen extends StatefulWidget {
  const ListingFormScreen({super.key, this.listing});

  final Listing? listing;

  bool get isEditing => listing != null;

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  late String _cropType;
  late String _location;
  DateTime? _availableFrom;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _cropType = listing?.cropType ?? ListingOptions.cropTypes.first;
    _location = listing?.location ?? ListingOptions.locations.first;
    _availableFrom = listing?.availableFrom;
    _photoPath = listing != null && ListingOptions.isAssetPhoto(listing.photoUrl)
        ? listing.photoUrl
        : ListingOptions.photoAssetFor(_cropType);
    if (listing != null) {
      _priceController.text = listing.pricePerKg.toStringAsFixed(0);
      _quantityController.text = listing.quantityKg.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSold = widget.listing?.isSoldOut ?? false;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _FormHeader(isEditing: widget.isEditing),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isSold) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.badgeSoldBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: AppColors.badgeSoldText,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This listing is sold and cannot be edited.',
                                  style: TextStyle(
                                    color: AppColors.badgeSoldText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _FieldLabel('Crop Type'),
                      _CropDropdown(
                        value: _cropType,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _cropType = value;
                              _photoPath = ListingOptions.photoAssetFor(value);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      _MarketPriceBanner(cropType: _cropType),
                      const SizedBox(height: 16),
                      _FieldLabel('Your Price (RWF/kg)'),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('e.g. 480'),
                        validator: (value) {
                          final parsed = double.tryParse(value ?? '');
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid price';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('Quantity Available (kg)'),
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        enabled: !isSold,
                        decoration: _inputDecoration(
                          widget.isEditing
                              ? 'e.g. 50 (set 0 when stock is empty)'
                              : 'e.g. 50',
                        ),
                        validator: (value) {
                          final parsed = double.tryParse(value ?? '');
                          if (parsed == null || parsed < 0) {
                            return 'Enter a valid quantity';
                          }
                          if (!widget.isEditing && parsed <= 0) {
                            return 'Quantity must be greater than zero';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('Available From'),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(10),
                        child: InputDecorator(
                          decoration: _inputDecoration('mm/dd/yyyy'),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _availableFrom == null
                                      ? 'mm/dd/yyyy'
                                      : '${_availableFrom!.month.toString().padLeft(2, '0')}/'
                                            '${_availableFrom!.day.toString().padLeft(2, '0')}/'
                                            '${_availableFrom!.year}',
                                  style: TextStyle(
                                    color: _availableFrom == null
                                        ? AppColors.captionGrey
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: AppColors.subtitleGrey,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel('Your Location'),
                      _LocationDropdown(
                        value: _location,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _location = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _PresetPhotoPicker(
                        selectedPhotoPath: _photoPath,
                        onSelected: (path) => setState(() => _photoPath = path),
                      ),
                      const SizedBox(height: 24),
                      BlocBuilder<ListingsCubit, ListingsState>(
                        builder: (context, state) {
                          final isSubmitting = state.isBusy;
                          return FilledButton(
                            onPressed: isSubmitting || isSold ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    widget.isEditing
                                        ? 'Save Changes →'
                                        : 'Post Listing →',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _availableFrom ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _availableFrom = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_availableFrom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose an available date.')),
      );
      return;
    }

    final input = ListingInput(
      cropType: _cropType,
      pricePerKg: double.parse(_priceController.text),
      quantityKg: double.parse(_quantityController.text),
      availableFrom: _availableFrom!,
      location: _location,
      photoPath: _photoPath,
      existingPhotoUrl: widget.listing?.photoUrl,
    );

    final cubit = context.read<ListingsCubit>();
    final success = widget.isEditing
        ? await cubit.updateListing(listingId: widget.listing!.id, input: input)
        : await cubit.createListing(input);

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primaryGreen,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            label: const Text('Back', style: TextStyle(color: Colors.white)),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Sell Produce',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              isEditing ? 'Edit your listing' : 'Create a new listing',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

class _CropDropdown extends StatelessWidget {
  const _CropDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      items: ListingOptions.cropTypes
          .map(
            (crop) => DropdownMenuItem(
              value: crop,
              child: Text('${ListingOptions.emojiFor(crop)}  $crop'),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _LocationDropdown extends StatelessWidget {
  const _LocationDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
      items: ListingOptions.locations
          .map(
            (location) =>
                DropdownMenuItem(value: location, child: Text(location)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _MarketPriceBanner extends StatelessWidget {
  const _MarketPriceBanner({required this.cropType});

  final String cropType;

  @override
  Widget build(BuildContext context) {
    final range = ListingOptions.marketPriceRange(cropType);
    if (range == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.marketPriceBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.marketPriceBorder.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.show_chart, color: Colors.blue.shade700, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Market price today: ${range.$1} – ${range.$2} RWF/kg',
              style: const TextStyle(
                color: AppColors.marketPriceBorder,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetPhotoPicker extends StatelessWidget {
  const _PresetPhotoPicker({
    required this.selectedPhotoPath,
    required this.onSelected,
  });

  final String? selectedPhotoPath;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel('Produce Photo'),
        if (selectedPhotoPath != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: ListingPhotoImage(
                photoUrl: selectedPhotoPath!,
                fallback: _selectedFallback(),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ListingOptions.presetPhotoAssets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final assetPath = ListingOptions.presetPhotoAssets[index];
              final cropType = ListingOptions.cropPhotoAssets.entries
                  .firstWhere((entry) => entry.value == assetPath)
                  .key;
              final isSelected = assetPath == selectedPhotoPath;

              return InkWell(
                onTap: () => onSelected(assetPath),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : AppColors.cardBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListingPhotoImage(
                          photoUrl: assetPath,
                          fallback: Center(
                            child: Text(
                              ListingOptions.emojiFor(cropType),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        color: isSelected
                            ? AppColors.primaryGreen
                            : Colors.grey.shade100,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          cropType.split(' ').first,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.subtitleGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _selectedFallback() {
    return Container(
      color: AppColors.marketPriceBg,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 36,
        color: AppColors.captionGrey,
      ),
    );
  }
}
