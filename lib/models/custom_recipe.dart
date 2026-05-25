import 'drink_order.dart';

/// A player-created boba recipe stored for the current session.
class CustomRecipe {
  const CustomRecipe({
    required this.id,
    required this.name,
    required this.ingredients,
  });

  final String id;
  final String name;
  final List<String> ingredients;

  DrinkOrder get order => DrinkOrder(ingredients: ingredients);

  static const nameSuggestions = [
    'Honey Cloud Boba',
    'Strawberry Star Tea',
    'Lavender Moon Milk',
    'Matcha Meadow Boba',
  ];

  static const teaBases = [
    'Black Tea',
    'Green Tea',
    'Strawberry Tea',
    'Matcha Tea',
  ];

  static const milks = [
    'Milk',
    'Oat Milk',
    'Coconut Milk',
  ];

  static const toppings = [
    'Tapioca Pearls',
    'Boba Jelly',
    'Strawberry Jelly',
  ];

  static const flavors = [
    'Honey Drizzle',
    'Vanilla',
    'Lavender',
    'Brown Sugar',
  ];

  /// Builds ingredient list from one pick per required group.
  static List<String> ingredientsFromSelections({
    required String? tea,
    required String? milk,
    required String? topping,
    String? flavor,
  }) {
    return [
      tea!,
      milk!,
      topping!,
      ?flavor,
    ];
  }

  static String generateName({
    required String? tea,
    required String? milk,
    required String? topping,
    required String? flavor,
    required int suggestionIndex,
  }) {
    if (tea != null &&
        milk != null &&
        topping != null &&
        flavor != null) {
      final flavorWord = flavor.split(' ').first;
      final teaWord = tea.split(' ').first;
      return '$flavorWord $teaWord Dream Boba';
    }
    return nameSuggestions[suggestionIndex % nameSuggestions.length];
  }
}
