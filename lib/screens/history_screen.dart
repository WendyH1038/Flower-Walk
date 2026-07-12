import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/walk.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DbService _db = DbService();
  List<Walk> _walks = [];

  final List<String> _walkEmojis = ['🌸', '🌻', '🌺', '🌼', '🌷', '🌹'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final walks = await _db.getWalks();
    setState(() => _walks = walks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9FB),
        elevation: 0,
        title: const Text(
          'walk history',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ),
      body: _walks.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🌱', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text(
                    'no walks yet!',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  Text(
                    'go plant some flowers 🌸',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _walks.length,
                itemBuilder: (context, i) {
                  final w = _walks[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.grey.shade100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _pastelColor(i),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              _walkEmojis[i % _walkEmojis.length],
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'walk ${i + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${w.dayLabel} · ${w.distanceKm.toStringAsFixed(2)} km · ${w.duration}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '+${w.flowerCount}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFE91E8C),
                              ),
                            ),
                            const Text(
                              'flowers',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _pastelColor(int i) {
    final colors = [
      const Color(0xFFFFD6E0),
      const Color(0xFFB5EAD7),
      const Color(0xFFC7CEEA),
      const Color(0xFFFDFD96),
      const Color(0xFFFFB7B2),
    ];
    return colors[i % colors.length];
  }
}
