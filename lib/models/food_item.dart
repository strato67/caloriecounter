class FoodItem {
// Class used for defining new food item to be added to meal plan

  // Attributes
  final int? id;
  final String name;
  final int calories;

  const FoodItem({
    // Do not require ID will let DB autoincrement and add
    this.id,
    required this.name,
    required this.calories,
  });

  // Converts food object to Map for database
  factory FoodItem.fromJson(Map<String, dynamic> json) =>
      FoodItem(id: json['id'], name: json['name'], calories: json['calories']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
      };
}
