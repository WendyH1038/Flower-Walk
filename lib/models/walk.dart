class Walk {
  final int? id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int stepCount;
  final int flowerCount;
  final double distanceKm;

  Walk({
    this.id,
    required this.startedAt,
    this.endedAt,
    this.stepCount = 0,
    this.flowerCount = 0,
    this.distanceKm = 0.0,
  });

  Walk copyWith({
    int? id,
    DateTime? startedAt,
    DateTime? endedAt,
    int? stepCount,
    int? flowerCount,
    double? distanceKm,
  }) => Walk(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    stepCount: stepCount ?? this.stepCount,
    flowerCount: flowerCount ?? this.flowerCount,
    distanceKm: distanceKm ?? this.distanceKm,
  );

  String get duration {
    if (endedAt == null) return '';
    final diff = endedAt!.difference(startedAt);
    final m = diff.inMinutes;
    return '$m min';
  }

  String get dayLabel {
    final now = DateTime.now();
    final diff = now.difference(startedAt).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    final months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    return '${months[startedAt.month - 1]} ${startedAt.day}';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'stepCount': stepCount,
    'flowerCount': flowerCount,
    'distanceKm': distanceKm,
  };

  factory Walk.fromMap(Map<String, dynamic> map) => Walk(
    id: map['id'],
    startedAt: DateTime.parse(map['startedAt']),
    endedAt: map['endedAt'] != null ? DateTime.parse(map['endedAt']) : null,
    stepCount: map['stepCount'],
    flowerCount: map['flowerCount'],
    distanceKm: map['distanceKm'],
  );
}
