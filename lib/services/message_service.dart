import 'dart:math';
import '../data/content.dart';
import 'db_service.dart';

class DailyMessageResult {
  final String reminder;
  final bool isMCQ;
  final String? blessing;
  final MCQ? mcq;

  DailyMessageResult({
    required this.reminder,
    required this.isMCQ,
    this.blessing,
    this.mcq,
  });
}

class MessageService {
  final DbService _db = DbService();
  final Random _random = Random();

  Future<DailyMessageResult?> getTodayMessages() async {
    final alreadyShownReminder = await _db.hasLoggedToday('reminder_popup');
    final alreadyShownMCQ = await _db.hasLoggedToday('mcq_popup');
    final blessingDue = await _isBlessingDue();

    if (alreadyShownReminder && alreadyShownMCQ && !blessingDue) {
      return null;
    }

    String? reminder;
    if (!alreadyShownReminder) {
      reminder = personalReminders[_random.nextInt(personalReminders.length)];
      await _db.logMessage('reminder_popup', reminder);
    }

    bool isMCQ = false;
    String? blessing;
    MCQ? mcq;

    if (!alreadyShownMCQ && calculusMCQs.isNotEmpty) {
      isMCQ = true;
      mcq = calculusMCQs[_random.nextInt(calculusMCQs.length)];
      await _db.logMessage('mcq_popup', mcq.question);
    }

    if (blessingDue) {
      final shownCount = await _db.countShownBlessings();
      final alreadyShownFinal = await _db.hasEverLogged('final_blessing');

      if (shownCount >= friendBlessings.length && !alreadyShownFinal) {
        // all blessings used up — show the final special message once
        blessing = finalBlessingMessage;
        await _db.logMessage('blessing', blessing);
        await _db.logMessage('final_blessing', 'shown');
      } else if (shownCount < friendBlessings.length &&
          friendBlessings.isNotEmpty) {
        blessing = friendBlessings[_random.nextInt(friendBlessings.length)];
        await _db.logMessage('blessing', blessing);
      }
      // if shownCount >= length AND final already shown: no more blessings, ever
    }

    return DailyMessageResult(
      reminder: reminder ?? '',
      isMCQ: isMCQ,
      blessing: blessing,
      mcq: mcq,
    );
  }

  Future<bool> _isBlessingDue() async {
    final lastShown = await _db.getLastShownDate('blessing');
    if (lastShown == null) return true;

    final now = DateTime.now();
    final daysSince = now.difference(lastShown).inDays;
    return daysSince >= 3;
  }
}
