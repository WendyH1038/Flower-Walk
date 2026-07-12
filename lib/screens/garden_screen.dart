import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../models/flower.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});
  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  final DbService _db = DbService();
  List<Flower> _flowers = [];
  int _total = 0;
  int _totalSteps = 0;

  final List<_Milestone> _milestones = [
    _Milestone(1, '🌱', 'first bloom'),
    _Milestone(10, '🌿', '10 flowers'),
    _Milestone(50, '🌸', '50 flowers'),
    _Milestone(100, '🌺', '100 flowers'),
    _Milestone(200, '🌻', '200 flowers'),
    _Milestone(500, '💐', 'flower queen'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final flowers = await _db.getTodayFlowers();
    final total = await _db.getTotalFlowers();
    final totalSteps = await _db.getTotalSteps();
    setState(() {
      _flowers = flowers;
      _total = total;
      _totalSteps = totalSteps;
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
              expandedHeight: 140,
              backgroundColor: const Color(0xFFFFB3C6),
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  "today's garden 🌸",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFB3C6), Color(0xFFB5EAD7)],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── total steps card ──────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFD6E0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFFB3C6,
                            ).withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD6E0),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text('👟', style: TextStyle(fontSize: 26)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'total steps walked',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$_totalSteps',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE91E8C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── today's flowers card ─────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB3C6), Color(0xFFFFC8DD)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text('🌸', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 8),
                          Text(
                            '${_flowers.length}',
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'flowers planted today',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'milestones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._milestones.map((m) {
                      final done = _total >= m.threshold;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: done
                              ? const Color(0xFFE8F5E9)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: done
                                ? const Color(0xFF81C784)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(m.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: done
                                          ? const Color(0xFF2E7D32)
                                          : Colors.grey,
                                    ),
                                  ),
                                  if (!done)
                                    Text(
                                      '${m.threshold - _total} more to go',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (done)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                              ),
                            if (!done)
                              const Icon(
                                Icons.lock_outline,
                                color: Colors.grey,
                                size: 18,
                              ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),
                    if (_flowers.isNotEmpty)
                      const Text(
                        "today's blooms",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (_flowers.isNotEmpty) const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            if (_flowers.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: Column(
                      children: [
                        Text('🌱', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          "no flowers yet today!",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'go for a walk to plant some 🌸',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (_flowers.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((context, i) {
                    final f = _flowers[i];
                    return Container(
                      decoration: BoxDecoration(
                        color: _pastelColor(i),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          f.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  }, childCount: _flowers.length),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
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
      const Color(0xFFE2F0CB),
    ];
    return colors[i % colors.length];
  }
}

class _Milestone {
  final int threshold;
  final String emoji;
  final String label;
  const _Milestone(this.threshold, this.emoji, this.label);
}
