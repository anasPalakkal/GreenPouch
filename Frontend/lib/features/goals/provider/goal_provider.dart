import 'package:flutter/material.dart';
import '../data/goal_model.dart';
import '../services/goal_service.dart';
import 'package:front_end/core/services/api_config.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _goalService;

  GoalProvider({GoalService? goalService})
      : _goalService = goalService ?? GoalService(baseUrl: "${ApiConfig.baseUrl}/api");

  List<GoalModel> _goals = [];
  List<GoalModel> _filteredGoals = [];
  
  bool _isLoading = false;
  String? _error; 

  List<GoalModel> get goals => _goals;
  List<GoalModel> get filteredGoals => _filteredGoals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _goalService.getGoals();
      _goals = data;
      _filteredGoals = data;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchGoals(String value) {
    _filteredGoals = _goals
        .where((g) =>
            g.title.toLowerCase().contains(value.toLowerCase()) ||
            g.category.toLowerCase().contains(value.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void showActiveGoals() {
    _filteredGoals = _goals.where((g) => g.progress < 1).toList();
    notifyListeners();
  }

  void showCompletedGoals() {
    _filteredGoals = _goals.where((g) => g.progress >= 1).toList();
    notifyListeners();
  }

  void showAllGoals() {
    _filteredGoals = _goals;
    notifyListeners();
  }

  Future<String?> createGoal(GoalModel goal) async {
    final result = await _goalService.createGoal(goal);
    if (result['success'] == true) {
      await fetchGoals();
      return null; 
    }
    return result['message'] ?? "Failed to create goal.";
  }

  Future<String?> updateGoal(GoalModel goal) async {
    final result = await _goalService.updateGoal(goal);
    if (result['success'] == true) {
      await fetchGoals();
      return null; 
    }
    return result['message'] ?? "Failed to update goal.";
  }

  Future<String?> deleteGoal(String id) async {
    final result = await _goalService.deleteGoal(id);

    if (result['success'] == true) {
      _goals.removeWhere((g) => g.id == id);
      _filteredGoals.removeWhere((g) => g.id == id);
      notifyListeners();
      return null; 
    } else {
      return result['message'] ?? "Failed to delete goal.";
    }
  }

  Future<List<dynamic>> getHistory(String goalId) {
    return _goalService.getGoalHistory(goalId);
  }
}