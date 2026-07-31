/// Static dropdown values used by the listing form and domain validation.
class ListingOptions {
  ListingOptions._();

  static const cropTypes = [
    'Tomatoes',
    'Green Peppers',
    'Onions',
    'Maize',
    'Beans',
  ];

  static const locations = ['Musanze', 'Kigali', 'Huye', 'Rubavu', 'Nyagatare'];

  static const cropEmojis = {
    'Tomatoes': '🍅',
    'Green Peppers': '🫑',
    'Onions': '🧅',
    'Maize': '🌽',
    'Beans': '🫘',
  };

  /// Bundled crop photos — add matching files under assets/images/.
  static const cropPhotoAssets = {
    'Tomatoes': 'assets/images/tomatoes.jpg',
    'Green Peppers': 'assets/images/green_peppers.jpg',
    'Onions': 'assets/images/onions.jpg',
    'Maize': 'assets/images/maize.jpg',
    'Beans': 'assets/images/beans.jpg',
  };

  static List<String> get presetPhotoAssets =>
      cropPhotoAssets.values.toList(growable: false);

  static String emojiFor(String cropType) => cropEmojis[cropType] ?? '🌾';

  static String photoAssetFor(String cropType) =>
      cropPhotoAssets[cropType] ?? presetPhotoAssets.first;

  static bool isAssetPhoto(String path) => path.startsWith('assets/');

  static bool isPresetPhoto(String path) => presetPhotoAssets.contains(path);

  /// Sample market price ranges shown on the create form (RWF/kg).
  static (int min, int max)? marketPriceRange(String cropType) {
    return switch (cropType) {
      'Tomatoes' => (450, 520),
      'Green Peppers' => (600, 750),
      'Onions' => (400, 480),
      'Maize' => (300, 380),
      'Beans' => (800, 950),
      _ => null,
    };
  }
}
