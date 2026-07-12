import 'package:flutter/material.dart';
import '../services/db_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final DbService _db = DbService();
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final logs = await _db.getMessageLog();
    final blessingsOnly = logs
        .where((log) => log['type'] == 'blessing')
        .toList();
    setState(() => _logs = blessingsOnly);
  }

  String _emojiFor(String type) {
    switch (type) {
      case 'Reminder':
        return '💌';
      case 'Blessing':
        return '🌸';
      case 'MCQ':
        return '🧮';
      default:
        return '✨';
    }
  }

  String _labelFor(String type) {
    switch (type) {
      case 'Reminder':
        return 'a little reminder';
      case 'Blessing':
        return 'a blessing';
      case 'MCQ':
        return 'math break';
      default:
        return 'message';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF9FB),
        elevation: 0,
        title: const Text(
          'messages 💌',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ),
      body: _logs.isEmpty
          ? const Center(
              child: Text(
                'no messages yet — come back tomorrow! 🌸',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _logs.length,
                itemBuilder: (context, i) {
                  final log = _logs[i];
                  final type = log['type'] as String;
                  final content = log['content'] as String;
                  final shownAt = DateTime.parse(log['shownAt'] as String);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _emojiFor(type),
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _labelFor(type),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                content,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${shownAt.month}/${shownAt.day}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
