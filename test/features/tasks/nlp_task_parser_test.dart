import 'package:flutter_test/flutter_test.dart';
import 'package:taskora/features/tasks/domain/nlp_task_parser.dart';
import 'package:taskora/features/tasks/domain/priority_enum.dart';
import 'package:taskora/features/tasks/domain/recurrence_enum.dart';

void main() {
  group('NlpTaskParser Tests', () {
    final fixedRefDate = DateTime(2026, 11, 24, 10, 0); // Tuesday, Nov 24, 2026

    test('parses full natural language task with all attributes', () {
      const input = 'Submit financial review tomorrow at 4pm !urgent #Work ~45m';
      final result = NlpTaskParser.parse(
        input,
        referenceDate: fixedRefDate,
      );

      expect(result.cleanTitle, equals('Submit financial review'));
      expect(result.dueDate, isNotNull);
      expect(result.dueDate!.day, equals(25)); // Nov 25
      expect(result.dueTime, isNotNull);
      expect(result.dueTime!.hour, equals(16)); // 4 PM
      expect(result.dueTime!.minute, equals(0));
      expect(result.priority, equals(TaskPriority.urgent));
      expect(result.category, isNotNull);
      expect(result.category!.id, equals('work'));
      expect(result.estimatedMinutes, equals(45));
      expect(result.hasAnyAttributes, isTrue);
    });

    test('parses relative offset days like "in 3 days"', () {
      const input = 'Dentist appointment in 3 days at 10:30am !high #Personal';
      final result = NlpTaskParser.parse(
        input,
        referenceDate: fixedRefDate,
      );

      expect(result.cleanTitle, equals('Dentist appointment'));
      expect(result.dueDate, isNotNull);
      expect(result.dueDate!.day, equals(27)); // Nov 27
      expect(result.dueTime!.hour, equals(10));
      expect(result.dueTime!.minute, equals(30));
      expect(result.priority, equals(TaskPriority.high));
      expect(result.category!.id, equals('personal'));
    });

    test('parses recurrence schedules like "every day" or "daily"', () {
      const input = 'Morning meditation daily at 7am #Health ~20m';
      final result = NlpTaskParser.parse(
        input,
        referenceDate: fixedRefDate,
      );

      expect(result.cleanTitle, equals('Morning meditation'));
      expect(result.recurrence, equals(TaskRecurrence.daily));
      expect(result.dueTime!.hour, equals(7));
      expect(result.category!.id, equals('health'));
      expect(result.estimatedMinutes, equals(20));
    });

    test('parses hours and minutes duration formats', () {
      final res1 = NlpTaskParser.parse('Deep coding session ~2h');
      expect(res1.estimatedMinutes, equals(120));

      final res2 = NlpTaskParser.parse('Quick bugfix ~15mins');
      expect(res2.estimatedMinutes, equals(15));
    });

    test('handles input without special attributes gracefully', () {
      const input = 'Buy groceries and fruits';
      final result = NlpTaskParser.parse(input);

      expect(result.cleanTitle, equals('Buy groceries and fruits'));
      expect(result.hasAnyAttributes, isFalse);
      expect(result.dueDate, isNull);
      expect(result.priority, isNull);
      expect(result.category, isNull);
    });

    test('correctly maps priority aliases like !p1 and !p2', () {
      final resP1 = NlpTaskParser.parse('Critical bug fix !p1');
      expect(resP1.priority, equals(TaskPriority.urgent));

      final resP2 = NlpTaskParser.parse('High priority feature !p2');
      expect(resP2.priority, equals(TaskPriority.high));
    });
  });
}
