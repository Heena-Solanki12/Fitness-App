// lib/views/workouts/workout_library_view.dart
import 'package:flutter/material.dart';
import '../../controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../controllers/workout_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/workout_model.dart';
import '../../models/workout_exercise.dart';
import '../../services/goal_recommendation_service.dart';

class WorkoutLibraryView extends StatelessWidget {
  final bool showBackButton;
  const WorkoutLibraryView({super.key, this.showBackButton = true});
  WorkoutController get controller => Get.put(WorkoutController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = ThemeController.to.isDark.value;
      return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(
          colors: isDark ? [AppColors.backgroundDark, Color(0xFF1C2128)] : [AppColors.backgroundLight, Colors.white],
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
        )),
        child: SafeArea(child: Column(children: [
          _appBar(isDark),
          _goalBanner(isDark),
          _searchBar(isDark),
          _filterRow(isDark),
          Expanded(child: Obx(() {
            if (controller.isLoading.value) return Center(child: CircularProgressIndicator(color: AppColors.primary));
            if (controller.filteredWorkouts.isEmpty) return _emptyState(isDark);
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: controller.filteredWorkouts.length,
              itemBuilder: (_, i) => _workoutCard(controller.filteredWorkouts[i], isDark),
            );
          })),
        ])),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (_) => _CreateWorkoutSheet(isDark: isDark, onCreate: (w) {
            controller.workouts.insert(0, w);
            controller.filteredWorkouts.insert(0, w);
          }),
        ),
        icon: const Icon(Icons.add), label: const Text('Create Workout'),
        backgroundColor: AppColors.primary,
      ),
    );
    });
  }

  Widget _appBar(bool isDark) => Container(
    padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
    decoration: BoxDecoration(
      color: isDark ? AppColors.cardDark : Colors.white,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
    ),
    child: Row(children: [
      if (showBackButton) IconButton(icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.textDark, size: 20), onPressed: () => Get.back()) else const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Workout Library', style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold)),
        Obx(() => Text('${controller.filteredWorkouts.length} workouts', style: TextStyle(color: AppColors.textGrey, fontSize: 12))),
      ])),
      GestureDetector(
        onTap: () => _filterSheet(isDark),
        child: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(Icons.tune, color: AppColors.primary, size: 20),
        ),
      ),
    ]),
  );

  Widget _goalBanner(bool isDark) => Obx(() {
    final goal = controller.userGoal.value;
    final config = GoalRecommendationService.getGoalConfig(goal);
    final c = Color(config['color'] as int);
    final recs = controller.recommendedWorkouts;
    if (recs.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.withOpacity(isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(Icons.auto_awesome, color: c, size: 15),
        const SizedBox(width: 8),
        Expanded(child: Text('${recs.length} workouts picked for "$goal"',
          style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.textDark, fontWeight: FontWeight.w500))),
        GestureDetector(onTap: () => controller.resetFilters(),
          child: Text('See All', style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold))),
      ]),
    );
  });

  Widget _searchBar(bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        onChanged: controller.setSearchQuery,
        style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Search workouts…', hintStyle: TextStyle(color: AppColors.textGrey),
          prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 20),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
            ? IconButton(icon: Icon(Icons.clear, color: AppColors.textGrey, size: 18), onPressed: () => controller.setSearchQuery(''))
            : const SizedBox.shrink()),
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    ),
  );

  Widget _filterRow(bool isDark) => SizedBox(
    height: 46,
    child: ListView(
      scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      children: ['All', 'Strength', 'Cardio', 'Flexibility', 'HIIT'].map((cat) =>
        Padding(padding: const EdgeInsets.only(right: 8),
          child: Obx(() => _chip(cat, controller.selectedCategory.value == cat, () => controller.setCategory(cat), isDark)))).toList(),
    ),
  );

  Widget _chip(String label, bool selected, VoidCallback onTap, bool isDark) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        gradient: selected ? LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]) : null,
        color: selected ? null : (isDark ? AppColors.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? Colors.transparent : Colors.grey.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : (isDark ? Colors.white70 : AppColors.textDark), fontWeight: selected ? FontWeight.w600 : FontWeight.w500, fontSize: 13)),
    ),
  );

  Widget _workoutCard(Workout workout, bool isDark) {
    final isRec = controller.recommendedWorkouts.any((r) => r.id == workout.id);
    final catColor = _catColor(workout.category);
    return GestureDetector(
      onTap: () => Get.toNamed('/workout-detail', arguments: workout),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isRec ? Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.18 : 0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
            child: SizedBox(width: 100, height: 100,
              child: workout.imageUrl != null
                ? CachedNetworkImage(imageUrl: workout.imageUrl!, fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _imgPlaceholder(catColor))
                : _imgPlaceholder(catColor),
            ),
          ),
          Expanded(child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                _badge(workout.category, catColor),
                if (isRec) ...[
                  const SizedBox(width: 6),
                  _badge('✦ For You', AppColors.primary),
                ],
                if (workout.isCustom ?? false) ...[
                  const SizedBox(width: 6),
                  _badge('Custom', Color(0xFF7C4DFF)),
                ],
              ]),
              const SizedBox(height: 6),
              Text(workout.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.timer_outlined, size: 12, color: AppColors.textGrey), const SizedBox(width: 3),
                Text('${workout.duration}m', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
                const SizedBox(width: 10),
                Icon(Icons.local_fire_department, size: 12, color: AppColors.textGrey), const SizedBox(width: 3),
                Text('${workout.caloriesBurned} cal', style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                ...List.generate(3, (i) => Icon(Icons.circle, size: 6,
                  color: i < _diffDots(workout.difficulty) ? _diffColor(workout.difficulty) : Colors.grey.withOpacity(0.3))),
                const SizedBox(width: 5),
                Text(workout.difficulty, style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
              ]),
            ]),
          )),
          Padding(padding: const EdgeInsets.only(top: 12, right: 12),
            child: Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey)),
        ]),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
  );

  Widget _imgPlaceholder(Color c) => Container(
    color: c.withOpacity(0.12),
    child: Center(child: Icon(Icons.fitness_center, color: c, size: 32)),
  );

  Widget _emptyState(bool isDark) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.search_off, size: 72, color: AppColors.textGrey.withOpacity(0.3)),
    const SizedBox(height: 16),
    Text('No workouts found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
    const SizedBox(height: 8),
    Text('Try adjusting filters', style: TextStyle(fontSize: 14, color: AppColors.textGrey)),
    const SizedBox(height: 24),
    ElevatedButton(onPressed: () => controller.resetFilters(),
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12)),
      child: const Text('Reset Filters')),
  ]));

  void _filterSheet(bool isDark) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Filter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
        const SizedBox(height: 16),
        Text('Difficulty', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textGrey)),
        const SizedBox(height: 10),
        Obx(() => Wrap(spacing: 8, runSpacing: 8, children: ['All', 'Beginner', 'Intermediate', 'Advanced'].map((d) =>
          ChoiceChip(label: Text(d), selected: controller.selectedDifficulty.value == d,
            onSelected: (_) => controller.setDifficulty(d), selectedColor: AppColors.primary,
            labelStyle: TextStyle(color: controller.selectedDifficulty.value == d ? Colors.white : AppColors.textGrey))).toList())),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: () { controller.resetFilters(); Get.back(); },
            style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Reset'))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('Apply'))),
        ]),
      ]),
    ));
  }

  Color _catColor(String c) { switch (c) { case 'Strength': return const Color(0xFF4E54C8); case 'Cardio': return const Color(0xFFFF6B9D); case 'HIIT': return const Color(0xFFFF8C00); default: return const Color(0xFF7C4DFF); } }
  int _diffDots(String d) { switch (d) { case 'Intermediate': return 2; case 'Advanced': return 3; default: return 1; } }
  Color _diffColor(String d) { switch (d) { case 'Beginner': return const Color(0xFF00B894); case 'Intermediate': return const Color(0xFFFDCB6E); default: return const Color(0xFFFF7675); } }
}

// ── Create Workout Sheet (StatefulWidget) ────────────────────────────────────
class _CreateWorkoutSheet extends StatefulWidget {
  final bool isDark;
  final Function(Workout) onCreate;
  const _CreateWorkoutSheet({required this.isDark, required this.onCreate});
  @override State<_CreateWorkoutSheet> createState() => _CreateWorkoutSheetState();
}

class _CreateWorkoutSheetState extends State<_CreateWorkoutSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _cat = 'Strength', _diff = 'Beginner';
  final List<Map<String, dynamic>> _exs = [];
  bool _saving = false;

  @override void dispose() { _nameCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  void _addExercise() {
    final n = TextEditingController(), s = TextEditingController(text: '3'), r = TextEditingController(text: '10'), w = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: widget.isDark ? AppColors.cardDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Add Exercise', style: TextStyle(color: widget.isDark ? Colors.white : AppColors.textDark, fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _dlgField(n, 'Exercise name', Icons.fitness_center),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _dlgField(s, 'Sets', Icons.repeat, num: true)),
          const SizedBox(width: 8),
          Expanded(child: _dlgField(r, 'Reps', Icons.format_list_numbered, num: true)),
          const SizedBox(width: 8),
          Expanded(child: _dlgField(w, 'kg', Icons.monitor_weight_outlined, dec: true)),
        ]),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: AppColors.textGrey))),
        TextButton(onPressed: () {
          if (n.text.trim().isEmpty) return;
          setState(() => _exs.add({'name': n.text.trim(), 'sets': int.tryParse(s.text) ?? 3, 'reps': int.tryParse(r.text) ?? 10, 'weight': w.text.trim().isEmpty ? null : double.tryParse(w.text)}));
          Navigator.pop(context);
        }, child: Text('Add', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
      ],
    ));
  }

  Widget _dlgField(TextEditingController c, String hint, IconData icon, {bool num = false, bool dec = false}) => Container(
    decoration: BoxDecoration(color: widget.isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(12)),
    child: TextField(controller: c,
      keyboardType: dec ? TextInputType.numberWithOptions(decimal: true) : num ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: widget.isDark ? Colors.white : AppColors.textDark, fontSize: 13),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 11),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 15), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10))),
  );

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Enter a workout name', backgroundColor: AppColors.error.withOpacity(0.1), colorText: AppColors.error, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
      return;
    }
    setState(() => _saving = true);
    final w = Workout(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(), description: _descCtrl.text.trim().isEmpty ? 'Custom workout' : _descCtrl.text.trim(),
      category: _cat, difficulty: _diff, duration: _exs.isEmpty ? 30 : _exs.length * 5 + 10,
      caloriesBurned: _exs.isEmpty ? 200 : _exs.length * 30 + 100,
      exercises: _exs.map((e) => WorkoutExercise(exerciseId: 'ex_${DateTime.now().millisecondsSinceEpoch}',
        name: e['name'] as String, sets: e['sets'] as int, reps: e['reps'] as int,
        weight: e['weight'] as double?, restTime: 60)).toList(),
      isCustom: true, tags: [_cat, 'Custom'],
    );
    widget.onCreate(w);
    Navigator.of(context).pop();
    Get.snackbar('Created! 🎉', '"${w.name}" added to library',
      backgroundColor: AppColors.primary.withOpacity(0.12), colorText: AppColors.primary,
      snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16), borderRadius: 12);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return Container(
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.fromLTRB(24, 14, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(3)))),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Create Workout', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          IconButton(icon: Icon(Icons.close, color: AppColors.textGrey), onPressed: () => Navigator.of(context).pop()),
        ]),
        const SizedBox(height: 20),
        _lbl('Workout Name *', isDark), const SizedBox(height: 8),
        _fld(_nameCtrl, 'e.g. Morning HIIT', Icons.fitness_center, isDark),
        const SizedBox(height: 14),
        _lbl('Description (optional)', isDark), const SizedBox(height: 8),
        _fld(_descCtrl, 'Brief description…', Icons.notes, isDark, lines: 2),
        const SizedBox(height: 20),
        _lbl('Category', isDark), const SizedBox(height: 10),
        Row(children: ['Strength', 'Cardio', 'Flexibility'].map((c) {
          final cc = c == 'Strength' ? const Color(0xFF4E54C8) : c == 'Cardio' ? const Color(0xFFFF6B9D) : const Color(0xFF7C4DFF);
          final sel = _cat == c;
          return Expanded(child: GestureDetector(onTap: () => setState(() => _cat = c),
            child: AnimatedContainer(duration: const Duration(milliseconds: 160),
              margin: EdgeInsets.only(right: c != 'Flexibility' ? 8 : 0), padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(color: sel ? cc.withOpacity(0.15) : (isDark ? AppColors.backgroundDark : const Color(0xFFF5F7FA)), borderRadius: BorderRadius.circular(13), border: sel ? Border.all(color: cc, width: 2) : null),
              child: Center(child: Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? cc : AppColors.textGrey))))));
        }).toList()),
        const SizedBox(height: 16),
        _lbl('Difficulty', isDark), const SizedBox(height: 10),
        Row(children: ['Beginner', 'Intermediate', 'Advanced'].map((d) {
          final dc = d == 'Beginner' ? const Color(0xFF00B894) : d == 'Intermediate' ? const Color(0xFFFDCB6E) : const Color(0xFFFF7675);
          final sel = _diff == d;
          return Expanded(child: GestureDetector(onTap: () => setState(() => _diff = d),
            child: AnimatedContainer(duration: const Duration(milliseconds: 160),
              margin: EdgeInsets.only(right: d != 'Advanced' ? 8 : 0), padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(gradient: sel ? LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd]) : null, color: sel ? null : (isDark ? AppColors.backgroundDark : const Color(0xFFF5F7FA)), borderRadius: BorderRadius.circular(13)),
              child: Center(child: Text(d, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppColors.textGrey))))));
        }).toList()),
        const SizedBox(height: 22),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Exercises', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
          TextButton.icon(onPressed: _addExercise, icon: Icon(Icons.add_circle, color: AppColors.primary, size: 18), label: Text('Add', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
        ]),
        if (_exs.isEmpty)
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(14)),
            child: Center(child: Column(children: [Icon(Icons.add_circle_outline, color: AppColors.textGrey.withOpacity(0.5), size: 32), const SizedBox(height: 8), Text('Tap Add to include exercises', style: TextStyle(color: AppColors.textGrey, fontSize: 13))])))
        else
          ..._exs.asMap().entries.map((e) => Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Container(width: 26, height: 26, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                child: Center(child: Text('${e.key + 1}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.value['name'] as String, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark, fontSize: 14)),
                Text('${e.value['sets']} sets × ${e.value['reps']} reps${e.value['weight'] != null ? ' · ${e.value['weight']}kg' : ''}', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              ])),
              IconButton(icon: Icon(Icons.delete_outline, color: AppColors.error, size: 18), onPressed: () => setState(() => _exs.removeAt(e.key))),
            ]),
          )),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: LinearGradient(colors: _saving ? [Colors.grey, Colors.grey] : [AppColors.primary, AppColors.gradientEnd]), borderRadius: BorderRadius.circular(18),
              boxShadow: _saving ? [] : [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))]),
            child: ElevatedButton(onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              child: _saving ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                : const Text('Create Workout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white))),
          )),
      ])),
    );
  }

  Widget _lbl(String t, bool isDark) => Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppColors.textGrey));
  Widget _fld(TextEditingController c, String hint, IconData icon, bool isDark, {int lines = 1}) => Container(
    decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(14)),
    child: TextField(controller: c, maxLines: lines, style: TextStyle(color: isDark ? Colors.white : AppColors.textDark, fontSize: 14),
      decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 18), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12))));
}
