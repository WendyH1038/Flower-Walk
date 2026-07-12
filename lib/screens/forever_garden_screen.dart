import 'package:flutter/material.dart';
import '../services/db_service.dart';

class ForeverGardenScreen extends StatefulWidget {
  const ForeverGardenScreen({super.key});
  @override
  State<ForeverGardenScreen> createState() => _ForeverGardenScreenState();
}

class _ForeverGardenScreenState extends State<ForeverGardenScreen> {
  final DbService _db = DbService();
  int _total = 0;
  int _totalSteps = 0;
  double _totalKm = 0;
  int _totalWalks = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final total = await _db.getTotalFlowers();
    final totalSteps = await _db.getTotalSteps();
    final walks = await _db.getWalks();
    final totalKm = walks.fold<double>(0, (sum, w) => sum + w.distanceKm);
    setState(() {
      _total = total;
      _totalSteps = totalSteps;
      _totalKm = totalKm;
      _totalWalks = walks.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FB),
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              backgroundColor: const Color(0xFFC7CEEA),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'forever garden 💐',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFC7CEEA), Color(0xFFFFB3C6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // big flower total
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC7CEEA), Color(0xFFB5EAD7)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text('💐', style: TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(
                            '$_total',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'flowers planted forever',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // grid of other lifetime stats
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            emoji: '👟',
                            value: '$_totalSteps',
                            label: 'total steps',
                            color: const Color(0xFFFFD6E0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            emoji: '📍',
                            value: _totalKm.toStringAsFixed(2),
                            label: 'km walked',
                            color: const Color(0xFFB5EAD7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            emoji: '🚶',
                            value: '$_totalWalks',
                            label: 'total walks',
                            color: const Color(0xFFC7CEEA),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            emoji: '🌱',
                            value: _totalWalks > 0
                                ? (_total / _totalWalks).toStringAsFixed(1)
                                : '0',
                            label: 'avg per walk',
                            color: const Color(0xFFFDFD96),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color color;
  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
