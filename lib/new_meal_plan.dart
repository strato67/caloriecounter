import 'package:flutter/material.dart';
import 'add_food.dart';
import 'database_helper.dart';
import 'models/food_item.dart';
import 'package:intl/intl.dart';
import 'models/meal_plan.dart';

class NewMealPlan extends StatefulWidget {
  final MealPlan? existingMealPlan;

  const NewMealPlan({Key? key, this.existingMealPlan}) : super(key: key);

  @override
  State<NewMealPlan> createState() => _NewMealPlanState();
}

class _NewMealPlanState extends State<NewMealPlan> {
  late MealPlan mealPlan;
  late bool isEditing;

  // Initialize variables
  DateTime? selectedDate;
  int totalCalories = 0;
  int maxCalories = 0;

  TextEditingController targetCaloriesController = TextEditingController();

  // Function to calculate total calorie count
  int calculateTotalCalories() {
    return mealPlan.foodItems.fold(0, (int total, FoodItem foodItem) {
      return total + (foodItem.calories ?? 0);
    });
  }

  // Initialize view when the screen loads
  @override
  void initState() {
    super.initState();
    isEditing = widget.existingMealPlan != null;

    // State if user is editing meal plan
    if (isEditing) {
      mealPlan = widget.existingMealPlan!;
    } else {
      // Otherwise user will create new meal plan
      mealPlan = MealPlan(
        date: DateTime.now(),
        foodItems: [],
        totalCalories: 0,
      );
    }
    targetCaloriesController.text = maxCalories.toString();
    totalCalories = calculateTotalCalories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Add Meal Plan'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              // Total Calories
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: TextField(
                  controller: targetCaloriesController,
                  decoration: const InputDecoration(
                    labelText: 'Target Calories',
                    border: InputBorder.none,
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Total Calories: ${mealPlan.totalCalories}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(getFormattedDate()),
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedFood = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddFood(mealPlan: mealPlan),
                    ),
                  );
                  if (selectedFood != null) {
                    setState(() {
                      // Adding new food item to meal plan list, then update calorie total
                      mealPlan.foodItems.add(selectedFood);
                      mealPlan.totalCalories = calculateTotalCalories();
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Add Food',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  int targetCalories =
                      int.tryParse(targetCaloriesController.text) ?? 0;

                  // Check that target calories and food items are added
                  if (mealPlan.totalCalories == 0 ||
                      mealPlan.foodItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Target calories and meal plan required.')),
                    );
                  } else if (mealPlan.totalCalories > targetCalories) {
                    // Check that user has not exceeded calorie limit set
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Total calories cannot exceed target calories')),
                    );
                  } else {
                    // Only use if user is editing meal plan
                    if (isEditing) {
                      await DatabaseHelper.updateMealPlan(mealPlan);
                    }
                    int id = await DatabaseHelper.addMealPlan(mealPlan);
                    if (id > 0) {
                      // Successfully saved meal plan
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Meal Plan saved successfully.')),
                      );
                    } else {
                      // Failure to save
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to save Meal Plan.')),
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: const Text(
                  'Save Meal',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0), // Adjust padding as needed
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      // Add margin bottom of 8
                      child: const Text(
                        'Selected Food Items:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),

                    for (final foodItem in mealPlan.foodItems)
                      Container(
                        width: 200,
                        margin: const EdgeInsets.only(bottom: 2),
                        child: Card(
                          child: InkWell(
                            onTap: () {
                              // Handle the image button tap
                              // You can navigate to another screen, show a dialog, etc.
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    '${foodItem.name}: ${foodItem.calories} Calories',
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                // Add an Image widget as a button
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      mealPlan.foodItems.remove(foodItem);
                                      mealPlan.totalCalories =
                                          calculateTotalCalories();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Display total calories
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Select Date function for adding to meal plan
  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = selectedDate ?? DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (date != null && date != selectedDate) {
      setState(() {
        selectedDate = date;

        // Using a temporary variable to hold the modified date
        DateTime updatedDate = date;

        // Update mealPlan.date only if not editing an existing meal plan
        if (!isEditing) {
          mealPlan = MealPlan(
            date: updatedDate,
            foodItems: mealPlan.foodItems,
            totalCalories: mealPlan.totalCalories,
          );
        }
      });
    }
  }

  // Format Date on Button
  String getFormattedDate() {
    if (selectedDate != null) {
      // Using DateFormat to format the selectedDate.
      return DateFormat.yMMMMd().format(selectedDate!);
    } else {
      return 'Select Date';
    }
  }
}
