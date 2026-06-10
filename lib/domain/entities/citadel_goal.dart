/// A Grande Meta — **A Cidadela**.
class CitadelGoal {
  final double target;
  final double saved;
  final DateTime deadline;

  const CitadelGoal({
    required this.target,
    required this.saved,
    required this.deadline,
  });

  double get progress =>
      target == 0 ? 0 : (saved / target).clamp(0, 1).toDouble();
  double get remaining => target - saved;

  int daysBehind(DateTime now) {
    final yearStart = DateTime(now.year);
    final totalDays = deadline.difference(yearStart).inDays;
    final elapsed = now.difference(yearStart).inDays;
    if (totalDays <= 0 || elapsed <= 0) return 0;

    final expected = target * (elapsed / totalDays);
    if (saved >= expected) return 0;

    final dailyRate = target / totalDays;
    if (dailyRate <= 0) return 0;
    return ((expected - saved) / dailyRate).ceil();
  }

  CitadelGoal copyWith({double? target, double? saved, DateTime? deadline}) =>
      CitadelGoal(
        target: target ?? this.target,
        saved: saved ?? this.saved,
        deadline: deadline ?? this.deadline,
      );

  Map<String, dynamic> toJson() => {
        'target': target,
        'saved': saved,
        'deadline': deadline.toIso8601String(),
      };

  factory CitadelGoal.fromJson(Map<String, dynamic> j) => CitadelGoal(
        target: (j['target'] as num).toDouble(),
        saved: (j['saved'] as num).toDouble(),
        deadline: DateTime.parse(j['deadline'] as String),
      );
}
