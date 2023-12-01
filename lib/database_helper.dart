import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models/food_item.dart';
import 'models/meal_plan.dart';

class DatabaseHelper {

  // Class used for database operations
  static const int _version = 1;
  static const String _dbname = "Food.db";

  // Create Tables
  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _dbname),
        onCreate: (db, version) async {
      await _createFoodTable(db);
      await _createMealPlanTable(db);
    }, version: _version);
  }

  // Table Schemas
  static Future<void> _createFoodTable(Database db) async {
    await db.execute(
      "CREATE TABLE Food("
      "id INTEGER PRIMARY KEY,"
      "name TEXT NOT NULL,"
      "calories INTEGER NOT NULL);",
    );

    // Default list of food items to be loaded
    var payload = [
      {"name": "Apple", "calories": 247},
      {"name": "Banana", "calories": 632},
      {"name": "Grapes", "calories": 419},
      {"name": "Orange", "calories": 222},
      {"name": "Pear", "calories": 343},
      {"name": "Peach", "calories": 281},
      {"name": "Pineapple", "calories": 343},
      {"name": "Strawberry", "calories": 222},
      {"name": "Watermelon", "calories": 209},
      {"name": "Asparagus", "calories": 113},
      {"name": "Broccoli", "calories": 188},
      {"name": "Carrots", "calories": 209},
      {"name": "Cucumber", "calories": 71},
      {"name": "Eggplant", "calories": 147},
      {"name": "Lettuce", "calories": 21},
      {"name": "Tomato", "calories": 92},
      {"name": "Beef", "calories": 595},
      {"name": "Chicken", "calories": 569},
      {"name": "Tofu", "calories": 360},
      {"name": "Egg", "calories": 327}
    ];
    payload.forEach((item) async {
      await db.insert("Food", item,
          conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  // Creating Meal Plan database table
  static Future<void> _createMealPlanTable(Database db) async {
    await db.execute(
      "CREATE TABLE MealPlan("
      "id INTEGER PRIMARY KEY,"
      "date TEXT NOT NULL,"
      "foodItems TEXT NOT NULL,"
      "totalCalories INTEGER NOT NULL);",
    );
  }

  // Method for adding new food item to database
  static Future<int> addFood(FoodItem food) async {
    final db = await _getDB();
    return await db.insert("Food", food.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Method for adding meal plan to database
  static Future<int> addMealPlan(MealPlan mealPlan) async {
    final db = await _getDB();
    return await db.insert("MealPlan", mealPlan.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Getting all food items from database
  static Future<List<FoodItem>> getAllFood() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("Food");

    return List.generate(
        maps.length, (index) => FoodItem.fromJson(maps[index]));
  }

  // Getting all meal plans from database
  static Future<List<MealPlan>> getAllMealPlans() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query("MealPlan");

    return List.generate(maps.length, (index) {
      final String foodItemsString = maps[index]['foodItems'];
      final List<dynamic> foodItemsData = jsonDecode(foodItemsString);
      final List<FoodItem> foodItems = foodItemsData
          .map(
              (itemData) => FoodItem.fromJson(itemData as Map<String, dynamic>))
          .toList();

      return MealPlan(
        id: maps[index]['id'],
        date: DateTime.parse(maps[index]['date']),
        foodItems: foodItems,
        totalCalories: maps[index]['totalCalories'],
      );
    });
  }

  // Updates existing meal plan from database
  static Future<int> updateMealPlan(MealPlan mealPlan) async {
    final db = await _getDB();
    return await db.update(
      'MealPlan',
      mealPlan.toJson(),
      where: 'id = ?',
      whereArgs: [mealPlan.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Deleting meal plan from database
  static Future<int> deleteMealPlan(MealPlan mealPlan) async {
    final db = await _getDB();
    return await db
        .delete('MealPlan', where: 'id = ?', whereArgs: [mealPlan.id]);
  }
}
