import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'models/food_item.dart';
import 'new_meal_plan.dart';
import 'models/meal_plan.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Meal Planner',
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController foodController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  List<MealPlan> mealPlans = [];

  @override
  void initState() {
    super.initState();
    _loadMealPlans();
  }

  void _loadMealPlans() async {
    List<MealPlan> fetchedMealPlans = await DatabaseHelper.getAllMealPlans();
    setState(() {
      mealPlans = fetchedMealPlans;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.food_bank_sharp),
            onPressed: () => _addFoodToDB(context),
            tooltip: 'Add Food Item',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: mealPlans.length,
        itemBuilder: (context, index) {
          final mealPlan = mealPlans[index];
          return Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(
                  'Meal Plan on ${DateFormat.yMMMMd().format(mealPlan.date)}',
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Total Calories: ${mealPlan.totalCalories}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                trailing: IconButton(
                  onPressed: () async {
                    await DatabaseHelper.deleteMealPlan(mealPlan);
                    setState(() {
                      // Assuming mealPlans is a List containing your meal plans
                      mealPlans.remove(mealPlan);
                    });
                  },
                  icon: const Icon(Icons.delete),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            NewMealPlan(existingMealPlan: mealPlan)),
                  );
                  _loadMealPlans();
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewMealPlan()),
          );
          _loadMealPlans();
        },
        tooltip: 'Create New Meal Plan',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addFoodToDB(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Food Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: foodController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: caloriesController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final String name = foodController.text;
                final int? calories = int.tryParse(caloriesController.text);
                // Check user has added name and calories
                if (name.isNotEmpty && calories != null) {
                  final foodItem = FoodItem(name: name, calories: calories);
                  // Add to database
                  await DatabaseHelper.addFood(foodItem);
                  // Clear the text fields
                  foodController.clear();
                  caloriesController.clear();
                  Navigator.of(context).pop(); // Close the dialog
                }
              },
              child: const Text('Submit'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
