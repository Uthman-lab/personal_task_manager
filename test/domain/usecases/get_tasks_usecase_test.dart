import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:interview_1/domain/model/task.dart';
import 'package:interview_1/domain/repositories/task_repository.dart';
import 'package:interview_1/domain/usecases/get_tasks_usecase.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  group('GetTasksUseCase Tests', () {
    late GetTasksUseCase useCase;
    late MockTaskRepository mockRepository;
    late List<Task> sampleTasks;

    setUp(() {
      mockRepository = MockTaskRepository();
      useCase = GetTasksUseCase(mockRepository);
      sampleTasks = [
        Task(
          id: '1',
          title: 'Task 1',
          dueDate: DateTime(2024, 1, 15),
          isCompleted: false,
        ),
        Task(
          id: '2',
          title: 'Task 2',
          dueDate: DateTime(2024, 1, 16),
          isCompleted: true,
        ),
        Task(
          id: '3',
          title: 'Task 3',
          dueDate: DateTime(2024, 1, 17),
          isCompleted: false,
        ),
      ];
    });

    group('Successful Operations', () {
      test('should return all tasks when repository call succeeds', () async {
        // Arrange
        when(() => mockRepository.getTasks())
            .thenAnswer((_) async => sampleTasks);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, equals(sampleTasks));
        expect(result.length, 3);
        verify(() => mockRepository.getTasks()).called(1);
      });

      test('should return empty list when no tasks exist', () async {
        // Arrange
        when(() => mockRepository.getTasks())
            .thenAnswer((_) async => []);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result, isEmpty);
        verify(() => mockRepository.getTasks()).called(1);
      });

      test('should return tasks with correct data structure', () async {
        // Arrange
        when(() => mockRepository.getTasks())
            .thenAnswer((_) async => sampleTasks);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result[0].id, '1');
        expect(result[0].title, 'Task 1');
        expect(result[0].dueDate, DateTime(2024, 1, 15));
        expect(result[0].isCompleted, false);
        
        expect(result[1].id, '2');
        expect(result[1].title, 'Task 2');
        expect(result[1].dueDate, DateTime(2024, 1, 16));
        expect(result[1].isCompleted, true);
      });

      test('should handle multiple consecutive calls', () async {
        // Arrange
        when(() => mockRepository.getTasks())
            .thenAnswer((_) async => sampleTasks);

        // Act
        final result1 = await useCase.call();
        final result2 = await useCase.call();

        // Assert
        expect(result1, equals(sampleTasks));
        expect(result2, equals(sampleTasks));
        verify(() => mockRepository.getTasks()).called(2);
      });
    });

    group('Error Handling', () {
      test('should propagate repository exceptions', () async {
        // Arrange
        final exception = Exception('Database connection failed');
        when(() => mockRepository.getTasks())
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => useCase.call(),
          throwsA(equals(exception)),
        );
        
        verify(() => mockRepository.getTasks()).called(1);
      });

      test('should handle repository timeout errors', () async {
        // Arrange
        when(() => mockRepository.getTasks())
            .thenThrow(TimeoutException('Request timeout', Duration(seconds: 30)));

        // Act & Assert
        expect(
          () => useCase.call(),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('should handle format exceptions', () async {
        // Arrange
        when(() => mockRepository.getTasks())
            .thenThrow(FormatException('Invalid data format'));

        // Act & Assert
        expect(
          () => useCase.call(),
          throwsA(isA<FormatException>()),
        );
      });

      test('should handle null data gracefully', () async {
        // Arrange
        when(() => mockRepository.getTasks())
            .thenThrow(StateError('Null data returned'));

        // Act & Assert
        expect(
          () => useCase.call(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle very large number of tasks', () async {
        // Arrange
        final largeTasks = List.generate(1000, (index) => Task(
          id: index.toString(),
          title: 'Task $index',
          dueDate: DateTime(2024, 1, 15).add(Duration(days: index)),
          isCompleted: index % 2 == 0,
        ));
        
        when(() => mockRepository.getTasks())
            .thenAnswer((_) async => largeTasks);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.length, 1000);
        expect(result.first.id, '0');
        expect(result.last.id, '999');
        verify(() => mockRepository.getTasks()).called(1);
      });

      test('should handle tasks with identical data', () async {
        // Arrange
        final identicalTasks = [
          Task(
            id: '1',
            title: 'Same Task',
            dueDate: DateTime(2024, 1, 15),
            isCompleted: false,
          ),
          Task(
            id: '2',
            title: 'Same Task',
            dueDate: DateTime(2024, 1, 15),
            isCompleted: false,
          ),
        ];
        
        when(() => mockRepository.getTasks())
            .thenAnswer((_) async => identicalTasks);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.length, 2);
        expect(result[0].title, result[1].title);
        expect(result[0].id, isNot(equals(result[1].id)));
      });

      test('should handle tasks with extreme dates', () async {
        // Arrange
        final extremeDateTasks = [
          Task(
            id: '1',
            title: 'Very Old Task',
            dueDate: DateTime(1900, 1, 1),
            isCompleted: false,
          ),
          Task(
            id: '2',
            title: 'Very Future Task',
            dueDate: DateTime(3000, 12, 31),
            isCompleted: false,
          ),
        ];
        
        when(() => mockRepository.getTasks())
            .thenAnswer((_) async => extremeDateTasks);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.length, 2);
        expect(result[0].dueDate.year, 1900);
        expect(result[1].dueDate.year, 3000);
      });

      test('should handle tasks with very long titles', () async {
        // Arrange
        final longTitleTasks = [
          Task(
            id: '1',
            title: 'A' * 10000,
            dueDate: DateTime(2024, 1, 15),
            isCompleted: false,
          ),
        ];
        
        when(() => mockRepository.getTasks())
            .thenAnswer((_) async => longTitleTasks);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result.length, 1);
        expect(result[0].title.length, 10000);
      });
    });

    group('Data Integrity', () {
      // test('should return immutable list', () async {
      //   // Arrange
      //   when(() => mockRepository.getTasks())
      //       .thenAnswer((_) async => sampleTasks);

      //   // Act
      //   final result = await useCase.call();
      //   final originalLength = result.length;

      //   // Try to modify the returned list
      //   try {
      //     result.add(Task(
      //       id: '999',
      //       title: 'New Task',
      //       dueDate: DateTime.now(),
      //       isCompleted: false,
      //     ));
      //   } catch (e) {
      //     // Expected for immutable lists
      //   }

      //   // Assert - original data should remain unchanged
      //   expect(result.length, originalLength);
      // });

      test('should maintain task completion states', () async {
        // Arrange
        when(() => mockRepository.getTasks())
            .thenAnswer((_) async => sampleTasks);

        // Act
        final result = await useCase.call();

        // Assert
        expect(result[0].isCompleted, false);
        expect(result[1].isCompleted, true);
        expect(result[2].isCompleted, false);
      });
    });

    tearDown(() {
      reset(mockRepository);
    });
  });
}

