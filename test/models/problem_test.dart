import 'package:flutter_test/flutter_test.dart';
import 'package:clock_learning/models/problem.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/five_minute_interval.dart';
import 'package:clock_learning/models/time.dart';

void main() {
  group('EasyProblem', () {
    test('かんたんレベルの問題を作成できる', () {
      final problem = Problem.easy(3);
      expect(problem.hour, 3);
      expect(problem.targetTime.minute, 0);
      expect(problem.level, Level.easy);
    });

    test('questionTextが正しく生成される', () {
      final problem = Problem.easy(3);
      expect(problem.questionText, '3時をあわせてください');
    });

    test('12時0分の問題を作成できる', () {
      final problem = Problem.easy(12);
      expect(problem.hour, 12);
      expect(problem.targetTime.minute, 0);
    });
  });

  group('NormalProblem', () {
    test('ふつうレベルの問題を作成できる', () {
      final problem = Problem.normal(3, FiveMinuteInterval.fifteen);
      expect(problem.hour, 3);
      expect(problem.targetTime.minute, 15);
      expect(problem.level, Level.normal);
    });

    test('questionTextが正しく生成される', () {
      final problem = Problem.normal(3, FiveMinuteInterval.fifteen);
      expect(problem.questionText, '3時15分をあわせてください');
    });

    test('5分刻みのすべての間隔で問題を作成できる', () {
      for (final interval in FiveMinuteInterval.values) {
        final problem = Problem.normal(3, interval);
        expect(problem.targetTime.minute, interval.value);
      }
    });
  });

  group('HardProblem', () {
    test('むずかしいレベルの問題を作成できる', () {
      final problem = Problem.hard(3, 15);
      expect(problem.hour, 3);
      expect(problem.targetTime.minute, 15);
      expect(problem.level, Level.hard);
    });

    test('questionTextが正しく生成される', () {
      final problem = Problem.hard(3, 15);
      expect(problem.questionText, '3時15分をあわせてください');
    });

    test('1分刻みの任意の分で問題を作成できる', () {
      for (int minute = 0; minute < 60; minute++) {
        final problem = Problem.hard(3, minute);
        expect(problem.targetTime.minute, minute);
      }
    });
  });

  group('Problem validation', () {
    test('かんたんレベルは分が0のみ', () {
      final problem = Problem.easy(3);
      expect(problem.targetTime.minute, 0);
    });

    test('ふつうレベルは5分刻みのみ', () {
      final problem = Problem.normal(3, FiveMinuteInterval.fifteen);
      expect(problem.targetTime.minute % 5, 0);
    });

    test('むずかしいレベルは任意の分', () {
      final problem = Problem.hard(3, 17);
      expect(problem.targetTime.minute, 17);
    });
  });
}
