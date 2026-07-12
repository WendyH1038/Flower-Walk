import 'dart:math';

class Flower {
  final int? id;
  final double latitude;
  final double longitude;
  final String emoji;
  final DateTime plantedAt;
  final int walkId;

  Flower({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.emoji,
    required this.plantedAt,
    required this.walkId,
  });

  static const List<String> emojis = [
    '🌸',
    '🌼',
    '🌺',
    '🌻',
    '🌷',
    '🌹',
    '💐',
    '🪷',
  ];

  static String randomEmoji() {
    final random = Random();
    return emojis[random.nextInt(emojis.length)];
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'emoji': emoji,
    'plantedAt': plantedAt.toIso8601String(),
    'walkId': walkId,
  };

  factory Flower.fromMap(Map<String, dynamic> map) => Flower(
    id: map['id'],
    latitude: map['latitude'],
    longitude: map['longitude'],
    emoji: map['emoji'],
    plantedAt: DateTime.parse(map['plantedAt']),
    walkId: map['walkId'],
  );
}
