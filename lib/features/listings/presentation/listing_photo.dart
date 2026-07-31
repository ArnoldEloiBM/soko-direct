import 'package:flutter/material.dart';

import '../domain/listing_options.dart';

/// Displays a listing photo from bundled assets or a legacy network URL.
class ListingPhotoImage extends StatelessWidget {
  const ListingPhotoImage({
    super.key,
    required this.photoUrl,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  final String photoUrl;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (ListingOptions.isAssetPhoto(photoUrl)) {
      return Image.asset(
        photoUrl,
        fit: fit,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    if (photoUrl.startsWith('http')) {
      return Image.network(
        photoUrl,
        fit: fit,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return fallback ?? const SizedBox.shrink();
  }
}
