// lib/views/exercises/exercise_library_view.dart
import 'package:flutter/material.dart';
import '../../controllers/theme_controller.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../models/exercise_model.dart';
import '../../services/exercise_service.dart';

class ExerciseLibraryView extends StatelessWidget {
  final bool showBackButton;
  const ExerciseLibraryView({super.key, this.showBackButton = true});
  ExerciseLibraryController get ctrl => Get.put(ExerciseLibraryController());

  static const _cats = ['All', 'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Cardio'];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = ThemeController.to.isDark.value;
      return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          colors: isDark ? [AppColors.backgroundDark, const Color(0xFF1C2128)] : [AppColors.backgroundLight, Colors.white],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        )),
        child: SafeArea(child: Column(children: [
          _appBar(isDark),
          _searchBar(isDark),
          _categoryFilter(isDark),
          _statsBar(isDark),
          Expanded(child: Obx(() {
            if (ctrl.isLoading.value) return Center(child: CircularProgressIndicator(color: AppColors.primary));
            if (ctrl.filtered.isEmpty) return _emptyState(isDark);
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: ctrl.filtered.length,
              itemBuilder: (_, i) => _exerciseCard(ctrl.filtered[i], isDark, context),
            );
          })),
        ])),
      ),
    );
    });
  }

  Widget _appBar(bool isDark) => Container(
    padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))]),
    child: Row(children: [
      if (showBackButton) IconButton(icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.textDark, size: 20), onPressed: () => Get.back()) else const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Exercise Library', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold)),
        Obx(() => Text('${ctrl.filtered.length} exercises', style: TextStyle(color: AppColors.textGrey, fontSize: 12))),
      ]),
    ]),
  );

  Widget _searchBar(bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Container(
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: TextField(onChanged: ctrl.setSearch, style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
        decoration: InputDecoration(hintText: 'Search exercises…', hintStyle: TextStyle(color: AppColors.textGrey),
          prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20),
          suffixIcon: Obx(() => ctrl.search.value.isNotEmpty
            ? IconButton(icon: Icon(Icons.clear, color: AppColors.textGrey, size: 18), onPressed: () => ctrl.setSearch(''))
            : const SizedBox.shrink()),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
    ),
  );

  Widget _categoryFilter(bool isDark) => SizedBox(
    height: 46,
    child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      children: _cats.map((c) => Padding(padding: const EdgeInsets.only(right: 8),
        child: Obx(() => _chip(c, ctrl.category.value == c, () => ctrl.setCategory(c), isDark)))).toList()),
  );

  Widget _chip(String label, bool sel, VoidCallback onTap, bool isDark) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: sel ? LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]) : null,
        color: sel ? null : (isDark ? AppColors.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sel ? Colors.transparent : Colors.grey.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(color: sel ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark), fontWeight: sel ? FontWeight.w700 : FontWeight.w500, fontSize: 13)),
    ),
  );

  Widget _statsBar(bool isDark) => Obx(() {
    if (ctrl.exercises.isEmpty) return const SizedBox.shrink();
    final byDiff = {'Beginner': 0, 'Intermediate': 0, 'Advanced': 0};
    for (final e in ctrl.exercises) byDiff[e.difficulty] = (byDiff[e.difficulty] ?? 0) + 1;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _statChip('${ctrl.exercises.length}', 'Total', AppColors.primary),
        _statChip('${byDiff['Beginner']}', 'Beginner', const Color(0xFF00B894)),
        _statChip('${byDiff['Intermediate']}', 'Intermediate', const Color(0xFFFDCB6E)),
        _statChip('${byDiff['Advanced']}', 'Advanced', const Color(0xFFFF7675)),
      ]),
    );
  });

  Widget _statChip(String count, String label, Color color) => Column(children: [
    Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
  ]);

  Widget _exerciseCard(Exercise ex, bool isDark, BuildContext context) {
    final catColor = _catColor(ex.category);
    return GestureDetector(
      onTap: () => _showDetail(ex, isDark, context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.18 : 0.05), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(color: catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
            child: Center(child: Icon(_catIcon(ex.category), color: catColor, size: 28))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ex.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 4),
            Text(ex.description, style: TextStyle(fontSize: 12, color: AppColors.textGrey), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 7),
            Wrap(spacing: 6, children: [
              _pill(ex.category, catColor),
              ...ex.primaryMuscles.take(2).map((m) => _pill(m, AppColors.primary.withOpacity(0.7))),
            ]),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            _diffBadge(ex.difficulty),
            const SizedBox(height: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
          ]),
        ])),
      ),
    );
  }

  Widget _pill(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
  );

  Widget _diffBadge(String diff) {
    final c = diff.toLowerCase() == 'beginner' ? const Color(0xFF00B894) : diff.toLowerCase() == 'intermediate' ? const Color(0xFFFDCB6E) : const Color(0xFFFF7675);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(diff, style: TextStyle(fontSize: 10, color: c, fontWeight: FontWeight.w700)));
  }

  Widget _emptyState(bool isDark) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.fitness_center, size: 72, color: AppColors.textGrey.withOpacity(0.3)), const SizedBox(height: 16),
    Text('No exercises found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
    const SizedBox(height: 8), Text('Try adjusting your search', style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
    const SizedBox(height: 24),
    ElevatedButton(onPressed: () { ctrl.setSearch(''); ctrl.setCategory('All'); },
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12)),
      child: const Text('Reset')),
  ]));

  void _showDetail(Exercise ex, bool isDark, BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _ExerciseDetailSheet(exercise: ex, isDark: isDark));
  }

  Color _catColor(String c) {
    switch (c.toLowerCase()) {
      case 'chest': return const Color(0xFF4E54C8);
      case 'back': return const Color(0xFF00B894);
      case 'legs': return const Color(0xFFFF8C00);
      case 'shoulders': return const Color(0xFF7C4DFF);
      case 'arms': return const Color(0xFFFF6B9D);
      case 'core': return const Color(0xFF00CEC9);
      case 'cardio': return const Color(0xFFFF5E3A);
      default: return AppColors.primary;
    }
  }

  IconData _catIcon(String c) {
    switch (c.toLowerCase()) {
      case 'chest': return Icons.accessibility_new;
      case 'back': return Icons.accessibility;
      case 'legs': return Icons.directions_walk;
      case 'shoulders': return Icons.person;
      case 'arms': return Icons.fitness_center;
      case 'core': return Icons.crop_square;
      case 'cardio': return Icons.directions_run;
      default: return Icons.fitness_center;
    }
  }
}

// ── Exercise Detail Sheet ────────────────────────────────────────────────────
class _ExerciseDetailSheet extends StatelessWidget {
  final Exercise exercise;
  final bool isDark;
  const _ExerciseDetailSheet({required this.exercise, required this.isDark});

  Color get _catColor {
    switch (exercise.category.toLowerCase()) {
      case 'chest': return const Color(0xFF4E54C8);
      case 'back': return const Color(0xFF00B894);
      case 'legs': return const Color(0xFFFF8C00);
      case 'shoulders': return const Color(0xFF7C4DFF);
      case 'arms': return const Color(0xFFFF6B9D);
      case 'core': return const Color(0xFF00CEC9);
      case 'cardio': return const Color(0xFFFF5E3A);
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
    decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
    child: Column(children: [
      Container(margin: const EdgeInsets.only(top: 12), width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(3))),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 64, height: 64, decoration: BoxDecoration(color: _catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(18)),
            child: Center(child: Icon(Icons.fitness_center, color: _catColor, size: 30))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(exercise.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 4),
            Row(children: [
              _badge(exercise.category, _catColor),
              const SizedBox(width: 8),
              _badge(exercise.difficulty, exercise.difficulty.toLowerCase() == 'beginner' ? const Color(0xFF00B894) : exercise.difficulty.toLowerCase() == 'intermediate' ? const Color(0xFFFDCB6E) : const Color(0xFFFF7675)),
            ]),
          ])),
          IconButton(icon: Icon(Icons.close, color: AppColors.textGrey), onPressed: () => Navigator.of(context).pop()),
        ]),
        const SizedBox(height: 20),
        Text(exercise.description, style: TextStyle(fontSize: 14, color: AppColors.textGrey, height: 1.5)),
        const SizedBox(height: 20),
        if (exercise.primaryMuscles.isNotEmpty) ...[
          _sectionTitle('Muscles Targeted', isDark),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: exercise.primaryMuscles.map((m) => _badge(m, _catColor)).toList()),
          const SizedBox(height: 20),
        ],
        if (exercise.equipment.isNotEmpty) ...[
          _sectionTitle('Equipment', isDark),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: exercise.equipment.map((e) => _badge(e, AppColors.textGrey)).toList()),
          const SizedBox(height: 20),
        ],
        if (exercise.instructions.isNotEmpty) ...[
          _sectionTitle('How To Do It', isDark),
          const SizedBox(height: 12),
          ...exercise.instructions.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 28, height: 28, decoration: BoxDecoration(color: _catColor.withOpacity(0.12), shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _catColor)))),
              const SizedBox(width: 12),
              Expanded(child: Text(e.value, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : AppColors.textGrey, height: 1.5))),
            ]))),
        ],
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: LinearGradient(colors: [_catColor, _catColor.withOpacity(0.7)]), borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: _catColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
            child: ElevatedButton.icon(
              onPressed: () { Navigator.of(context).pop(); Get.toNamed('/workout-library'); },
              icon: const Icon(Icons.add, color: Colors.white), label: const Text('Add to Workout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)))),
          )),
      ]))),
    ]),
  );

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
  );

  Widget _sectionTitle(String title, bool isDark) => Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark));
}

// ── Controller ───────────────────────────────────────────────────────────────
class ExerciseLibraryController extends GetxController {
  final RxList<Exercise> exercises = <Exercise>[].obs;
  final RxList<Exercise> filtered = <Exercise>[].obs;
  final RxBool isLoading = false.obs;
  final RxString category = 'All'.obs;
  final RxString search = ''.obs;

  @override
  void onInit() { super.onInit(); _load(); }

  void _load() {
    isLoading.value = true;
    exercises.value = ExerciseService.getInitialExercises();
    filtered.value = exercises;
    isLoading.value = false;
  }

  void setCategory(String c) { category.value = c; _filter(); }
  void setSearch(String q) { search.value = q; _filter(); }

  void _filter() {
    filtered.value = exercises.where((e) {
      final matchCat = category.value == 'All' || e.category.toLowerCase() == category.value.toLowerCase() || e.primaryMuscles.any((m) => m.toLowerCase().contains(category.value.toLowerCase()));
      final q = search.value.toLowerCase();
      final matchSearch = q.isEmpty || e.name.toLowerCase().contains(q) || e.description.toLowerCase().contains(q) || e.primaryMuscles.any((m) => m.toLowerCase().contains(q));
      return matchCat && matchSearch;
    }).toList();
  }
}
