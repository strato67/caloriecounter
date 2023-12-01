import 'dart:convert';

import 'food_item.dart';

class MealPlan {
  // Class used for defining new meal plan to be saved and retrieved from database
  final int? id;
  final DateTime date;
  final List<FoodItem> foodItems;
  late int totalCalories;

  MealPlan(
      {this.id,
      required this.date,
      required this.foodItems,
      required this.totalCalories});

  //Map to insert into database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      // Convert the list of FoodItem objects to a JSON string
      'foodItems':
          jsonEncode(foodItems.map((foodItem) => foodItem.toJson()).toList()),
      'totalCalories': totalCalories,
    };
  }

  // Creates MealPlan object from JSON object
  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
        id: json['id'],
        date: DateTime.parse(json['date']),
        foodItems: (json['foodItems'] as List<dynamic>)
            .map((itemData) => FoodItem.fromJson(itemData))
            .toList(),
        totalCalories: json['totalCalories'],
      );
}
