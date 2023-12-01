import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/meal_plan.dart';

class MealPlanSearch extends SearchDelegate<String> {
  final List<MealPlan> mealPlans;

  MealPlanSearch(this.mealPlans);

  @override
  String get searchFieldLabel => 'Search by Date';

  @override
  List<Widget> buildActions(BuildContext context) {
    // Actions for the AppBar (e.g., clear the search query)
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Leading icon on the left of the AppBar (e.g., back button)
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Show search results based on the query
    final List<MealPlan> results = mealPlans
        .where((mealPlan) =>
    DateFormat.yMMMMd().format(mealPlan.date).contains(query) ||
        mealPlan.totalCalories.toString().contains(query))
        .toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions while typing in the search bar
    final List<MealPlan> suggestions = mealPlans
        .where((mealPlan) =>
    DateFormat.yMMMMd().format(mealPlan.date).contains(query) ||
        mealPlan.totalCalories.toString().contains(query))
        .toList();

    return _buildSearchResults(suggestions);
  }

  Widget _buildSearchResults(List<MealPlan> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final mealPlan = results[index];
        return ListTile(
          title: Text('Meal Plan on ${DateFormat.yMMMMd().format(mealPlan.date)}'),
          subtitle: Text('Total Calories: ${mealPlan.totalCalories}'),
          onTap: () {
            close(context, mealPlan.date.toString()); // You can pass back the selected result
          },
        );
      },
    );
  }
}