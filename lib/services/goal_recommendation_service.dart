// lib/services/goal_recommendation_service.dart
import '../models/workout_model.dart';
import '../models/workout_exercise.dart';

class GoalRecommendationService {
  static const Map<String, Map<String, dynamic>> goalConfig = {
    'Lose Weight': {
      'primaryCategory': 'Cardio',
      'secondaryCategory': 'Strength',
      'preferredDifficulty': ['Beginner', 'Intermediate'],
      'message': 'Burn fat with cardio & strength circuits',
      'tip': 'Aim for 3-4 cardio sessions + 2 strength sessions per week',
      'weeklyWorkouts': 5,
      'tags': ['HIIT', 'Fat Burning', 'Cardio', 'Full Body'],
      'icon': 'trending_down',
      'color': 0xFFFF6B9D,
    },
    'Gain Muscle': {
      'primaryCategory': 'Strength',
      'secondaryCategory': 'Strength',
      'preferredDifficulty': ['Intermediate', 'Advanced'],
      'message': 'Build strength with progressive overload',
      'tip': 'Focus on compound lifts and progressive overload',
      'weeklyWorkouts': 4,
      'tags': ['Strength', 'Muscle Building', 'Upper Body', 'Lower Body'],
      'icon': 'fitness_center',
      'color': 0xFF4E54C8,
    },
    'Stay Fit': {
      'primaryCategory': 'Strength',
      'secondaryCategory': 'Flexibility',
      'preferredDifficulty': ['Beginner', 'Intermediate'],
      'message': 'Balanced fitness for a healthy lifestyle',
      'tip': 'Mix strength, cardio, and flexibility work',
      'weeklyWorkouts': 3,
      'tags': ['Full Body', 'Yoga', 'Flexibility', 'Core'],
      'icon': 'favorite',
      'color': 0xFF00D4AA,
    },
  };

  /// Returns workouts recommended for a given goal and fitness level
  static List<Workout> getRecommendedWorkouts({
    required String goal,
    required String level,
    required List<Workout> allWorkouts,
    int limit = 4,
  }) {
    final config = goalConfig[goal] ?? goalConfig['Stay Fit']!;
    final primaryCategory = config['primaryCategory'] as String;
    final secondaryCategory = config['secondaryCategory'] as String;
    final preferredDifficulty = config['preferredDifficulty'] as List;
    final tags = config['tags'] as List;

    // Score each workout
    final scored = allWorkouts.map((w) {
      int score = 0;

      // Category match
      if (w.category == primaryCategory) score += 5;
      if (w.category == secondaryCategory) score += 2;

      // Difficulty match
      if (preferredDifficulty.contains(w.difficulty)) score += 3;
      if (w.difficulty == level) score += 2;

      // Tag match
      for (final tag in w.tags) {
        if (tags.contains(tag)) score += 1;
      }

      return MapEntry(w, score);
    }).toList();

    // Sort by score descending
    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored.take(limit).map((e) => e.key).toList();
  }

  /// Returns today's recommended workout based on goal + level
  static Workout? getTodaysWorkout({
    required String goal,
    required String level,
    required List<Workout> allWorkouts,
    required int completedThisWeek,
  }) {
    final config = goalConfig[goal] ?? goalConfig['Stay Fit']!;
    final weeklyTarget = config['weeklyWorkouts'] as int;

    if (completedThisWeek >= weeklyTarget) return null;

    // Alternate: if even day pick primary, odd pick secondary
    final isEvenDay = DateTime.now().weekday % 2 == 0;
    final category = isEvenDay
        ? config['primaryCategory'] as String
        : config['secondaryCategory'] as String;

    final candidates = allWorkouts.where((w) {
      return w.category == category &&
          (w.difficulty == level ||
              (level == 'Beginner' && w.difficulty == 'Beginner') ||
              (level == 'Intermediate' &&
                  (w.difficulty == 'Beginner' ||
                      w.difficulty == 'Intermediate')));
    }).toList();

    if (candidates.isEmpty) return allWorkouts.isNotEmpty ? allWorkouts.first : null;
    candidates.shuffle();
    return candidates.first;
  }

  static Map<String, dynamic> getGoalConfig(String goal) {
    return goalConfig[goal] ?? goalConfig['Stay Fit']!;
  }

  static String getMotivationalMessage(String goal, int streak) {
    if (streak == 0) {
      switch (goal) {
        case 'Lose Weight':
          return 'Every journey starts with a single step. Start today! 🔥';
        case 'Gain Muscle':
          return 'Your muscles are waiting to be built. Let\'s go! 💪';
        default:
          return 'A healthier you starts now. Let\'s move! ❤️';
      }
    } else if (streak < 7) {
      return 'Great start! $streak day streak. Keep going! 🚀';
    } else if (streak < 30) {
      return '$streak days strong! You\'re building a habit! 🔥';
    } else {
      return '$streak days! You\'re unstoppable! 🏆';
    }
  }

  static List<Map<String, dynamic>> getWeeklyPlan(String goal, String level) {
    final config = goalConfig[goal] ?? goalConfig['Stay Fit']!;

    switch (goal) {
      case 'Lose Weight':
        return [
          {'day': 'Mon', 'type': 'HIIT Cardio', 'focus': 'Fat Burn', 'active': true},
          {'day': 'Tue', 'type': 'Strength', 'focus': 'Full Body', 'active': true},
          {'day': 'Wed', 'type': 'Rest / Walk', 'focus': 'Recovery', 'active': false},
          {'day': 'Thu', 'type': 'Cardio', 'focus': 'Endurance', 'active': true},
          {'day': 'Fri', 'type': 'Strength', 'focus': 'Upper Body', 'active': true},
          {'day': 'Sat', 'type': 'HIIT', 'focus': 'Fat Burn', 'active': true},
          {'day': 'Sun', 'type': 'Rest', 'focus': 'Recovery', 'active': false},
        ];
      case 'Gain Muscle':
        return [
          {'day': 'Mon', 'type': 'Chest & Triceps', 'focus': 'Push', 'active': true},
          {'day': 'Tue', 'type': 'Back & Biceps', 'focus': 'Pull', 'active': true},
          {'day': 'Wed', 'type': 'Legs', 'focus': 'Lower', 'active': true},
          {'day': 'Thu', 'type': 'Rest', 'focus': 'Recovery', 'active': false},
          {'day': 'Fri', 'type': 'Shoulders', 'focus': 'Push', 'active': true},
          {'day': 'Sat', 'type': 'Full Body', 'focus': 'Strength', 'active': true},
          {'day': 'Sun', 'type': 'Rest', 'focus': 'Recovery', 'active': false},
        ];
      default:
        return [
          {'day': 'Mon', 'type': 'Full Body', 'focus': 'Strength', 'active': true},
          {'day': 'Tue', 'type': 'Yoga Flow', 'focus': 'Flexibility', 'active': true},
          {'day': 'Wed', 'type': 'Rest / Walk', 'focus': 'Recovery', 'active': false},
          {'day': 'Thu', 'type': 'Cardio', 'focus': 'Cardio', 'active': true},
          {'day': 'Fri', 'type': 'Core', 'focus': 'Abs', 'active': true},
          {'day': 'Sat', 'type': 'Stretching', 'focus': 'Mobility', 'active': true},
          {'day': 'Sun', 'type': 'Rest', 'focus': 'Recovery', 'active': false},
        ];
    }
  }
}
