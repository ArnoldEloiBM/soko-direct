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

  static String emojiFor(String cropType) => cropEmojis[cropType] ?? '🌾';

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
