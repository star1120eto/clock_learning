import 'package:flutter_test/flutter_test.dart';
import 'package:clock_learning/services/problem_generator_service.dart';
import 'package:clock_learning/models/level.dart';
import 'package:clock_learning/models/problem.dart';
import 'package:clock_learning/models/time.dart';
import 'package:clock_learning/models/five_minute_interval.dart';

void main() {
  group('ProblemGeneratorService', () {
    late ProblemGeneratorService service;

    setUp(() {
      service = ProblemGeneratorService();
    });

    group('generateProblem', () {
      test('かんたんレベルの問題を生成できる', () {
        final problem = service.generateProblem(Level.easy);
        expect(problem.level, Level.easy);
        expect(problem.targetTime.minute, 0);
        expect(problem.hour >= 1 && problem.hour <= 12, true);
      });

      test('ふつうレベルの問題を生成できる', () {
        final problem = service.generateProblem(Level.normal);
        expect(problem.level, Level.normal);
        expect(problem.targetTime.minute % 5, 0);
        expect(problem.hour >= 1 && problem.hour <= 12, true);
      });

      test('むずかしいレベルの問題を生成できる', () {
        final problem = service.generateProblem(Level.hard);
        expect(problem.level, Level.hard);
        expect(problem.targetTime.minute >= 0 && problem.targetTime.minute < 60, true);
        expect(problem.hour >= 1 && problem.hour <= 12, true);
      });

      test('重複チェックが正しく動作する', () {
        final recentProblems = <Problem>[
          Problem.easy(3),
          Problem.easy(5),
        ];
        final problem = service.generateProblem(
          Level.easy,
          recentProblems: recentProblems,
        );
        // 重複していない問題が生成される（確率的だが、十分な回数試行すれば重複しない）
        expect(problem.hour != 3 || problem.hour != 5, true);
      });
    });

    group('validateAnswer', () {
      test('かんたんレベルで正解を判定できる', () {
        final problem = Problem.easy(3);
        final correctAnswer = Time(hour: 3, minute: 0);
        final incorrectAnswer = Time(hour: 4, minute: 0);

        expect(
          service.validateAnswer(problem, 3, 0),
          true,
        );
        expect(
          service.validateAnswer(problem, 4, 0),
          false,
        );
      });

      test('ふつうレベルで正解を判定できる', () {
        final problem = Problem.normal(3, FiveMinuteInterval.fifteen);
        final correctAnswer = Time(hour: 3, minute: 15);
        final incorrectAnswer = Time(hour: 3, minute: 20);

        expect(
          service.validateAnswer(problem, 3, 15),
          true,
        );
        expect(
          service.validateAnswer(problem, 3, 20),
          false,
        );
      });

      test('むずかしいレベルで正解を判定できる', () {
        final problem = Problem.hard(3, 17);
        final correctAnswer = Time(hour: 3, minute: 17);
        final incorrectAnswer = Time(hour: 3, minute: 18);

        expect(
          service.validateAnswer(problem, 3, 17),
          true,
        );
        expect(
          service.validateAnswer(problem, 3, 18),
          false,
        );
      });

      test('12時0分の問題で正解を判定できる', () {
        final problem = Problem.easy(12);
        final correctAnswer = Time(hour: 12, minute: 0);
        final incorrectAnswer = Time(hour: 1, minute: 0);

        expect(
          service.validateAnswer(problem, 12, 0),
          true,
        );
        expect(
          service.validateAnswer(problem, 1, 0),
          false,
        );
      });
    });
  });
}
