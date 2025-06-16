import 'package:flutter_test/flutter_test.dart';
import 'package:interview_1/domain/model/task.dart';

void main() {
  group('Task Model Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
    });

    group('Task Constructor', () {
      test('should create task with all required fields', () {
        // Arrange & Act
        final task = Task(
          id: '123',
          title: 'Test Task',
          dueDate: testDate,
          isCompleted: false,
        );

        // Assert
        expect(task.id, '123');
        expect(task.title, 'Test Task');
        expect(task.dueDate, testDate);
        expect(task.isCompleted, false);
      });

      test('should allow isCompleted to be modified', () {
        // Arrange
        final task = Task(
          id: '123',
          title: 'Test Task',
          dueDate: testDate,
          isCompleted: false,
        );

        // Act
        task.isCompleted = true;

        // Assert
        expect(task.isCompleted, true);
      });
    });

    group('Task.create Constructor', () {
      test('should create task with auto-generated ID', () {
        // Arrange & Act
        final task = Task.create(
          title: 'Test Task',
          dueDate: testDate,
          isCompleted: false,
        );

        // Assert
        expect(task.id, isNotEmpty);
        expect(task.title, 'Test Task');
        expect(task.dueDate, testDate);
        expect(task.isCompleted, false);
      });
    });

    group('Task Serialization', () {
      test('should convert task to map correctly', () {
        // Arrange
        final task = Task(
          id: '123',
          title: 'Test Task',
          dueDate: testDate,
          isCompleted: true,
        );

        // Act
        final map = task.toMap();

        // Assert
        expect(map['id'], '123');
        expect(map['title'], 'Test Task');
        expect(map['dueDate'], testDate.toIso8601String());
        expect(map['isCompleted'], true);
      });

      test('should create task from map correctly', () {
        // Arrange
        final map = {
          'id': '123',
          'title': 'Test Task',
          'dueDate': testDate.toIso8601String(),
          'isCompleted': true,
        };

        // Act
        final task = Task.fromMap(map);

        // Assert
        expect(task.id, '123');
        expect(task.title, 'Test Task');
        expect(task.dueDate, testDate);
        expect(task.isCompleted, true);
      });

      test('should handle missing ID in map by generating one', () {
        // Arrange
        final map = {
          'title': 'Test Task',
          'dueDate': testDate.toIso8601String(),
          'isCompleted': false,
        };

        // Act
        final task = Task.fromMap(map);

        // Assert
        expect(task.id, isNotEmpty);
        expect(task.title, 'Test Task');
        expect(task.dueDate, testDate);
        expect(task.isCompleted, false);
      });

      test('should handle serialization round trip correctly', () {
        // Arrange
        final originalTask = Task(
          id: '123',
          title: 'Test Task',
          dueDate: testDate,
          isCompleted: false,
        );

        // Act
        final map = originalTask.toMap();
        final recreatedTask = Task.fromMap(map);

        // Assert
        expect(recreatedTask.id, originalTask.id);
        expect(recreatedTask.title, originalTask.title);
        expect(recreatedTask.dueDate, originalTask.dueDate);
        expect(recreatedTask.isCompleted, originalTask.isCompleted);
      });
    });

    group('Edge Cases', () {
      test('should handle empty title', () {
        // Arrange & Act
        final task = Task(
          id: '123',
          title: '',
          dueDate: testDate,
          isCompleted: false,
        );

        // Assert
        expect(task.title, '');
      });

      test('should handle very long title', () {
        // Arrange
        final longTitle = 'A' * 1000;

        // Act
        final task = Task(
          id: '123',
          title: longTitle,
          dueDate: testDate,
          isCompleted: false,
        );

        // Assert
        expect(task.title, longTitle);
        expect(task.title.length, 1000);
      });

      test('should handle past dates', () {
        // Arrange
        final pastDate = DateTime(2020, 1, 1);

        // Act
        final task = Task(
          id: '123',
          title: 'Past Task',
          dueDate: pastDate,
          isCompleted: false,
        );

        // Assert
        expect(task.dueDate, pastDate);
      });

      test('should handle future dates', () {
        // Arrange
        final futureDate = DateTime(2030, 12, 31);

        // Act
        final task = Task(
          id: '123',
          title: 'Future Task',
          dueDate: futureDate,
          isCompleted: false,
        );

        // Assert
        expect(task.dueDate, futureDate);
      });
    });
  });
}
