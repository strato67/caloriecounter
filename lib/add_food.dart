import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/food_item.dart';
import 'models/meal_plan.dart';

class AddFood extends StatefulWidget {
  final MealPlan mealPlan;

  const AddFood({super.key, required this.mealPlan});

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  List<FoodItem> foodItems = []; // List to hold food items from the database

  @override
  void initState() {
    super.initState();
    // Load food items from the database when the screen is initialized
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    // Use your DatabaseHelper to get all food items from the database
    final List<FoodItem> items = await DatabaseHelper.getAllFood();
    setState(() {
      foodItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food'),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.builder(
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          final foodItem = foodItems[index];
          return ListTile(
            title: Text(foodItem.name),
            subtitle: Text('${foodItem.calories} Calories'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pop(
                    context, foodItem); //Return selected food item to meal plan
              },
            ),
          );
        },
      ),
    );
  }
}
