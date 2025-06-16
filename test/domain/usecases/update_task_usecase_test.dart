import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:interview_1/domain/model/task.dart';
import 'package:interview_1/domain/repositories/task_repository.dart';
import 'package:interview_1/domain/usecases/update_task_usecase.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  group('UpdateTaskUseCase Tests', () {
    late UpdateTaskUseCase useCase;
    late MockTaskRepository mockRepository;
    late Task testTask;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(Task(
        id: 'fallback',
        title: 'Fallback Task',
        dueDate: DateTime.now(),
        isCompleted: false,
      ));
    });

    setUp(() {
      mockRepository = MockTaskRepository();
      useCase = UpdateTaskUseCase(mockRepository);
      testTask = Task(
        id: '123',
        title: 'Test Task',
        dueDate: DateTime(2024, 1, 15),
        isCompleted: false,
      );
    });

    group('Successful Operations', () {
      test('should update task successfully when repository call succeeds', () async {
        // Arrange
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(testTask);

        // Assert
        verify(() => mockRepository.updateTask(testTask)).called(1);
      });

      test('should call repository with correct task data', () async {
        // Arrange
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(testTask);

        // Assert
        final captured = verify(() => mockRepository.updateTask(captureAny())).captured;
        final capturedTask = captured.first as Task;
        
        expect(capturedTask.id, testTask.id);
        expect(capturedTask.title, testTask.title);
        expect(capturedTask.dueDate, testTask.dueDate);
        expect(capturedTask.isCompleted, testTask.isCompleted);
      });

      test('should handle updating task completion status', () async {
        // Arrange
        testTask.isCompleted = true;
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(testTask);

        // Assert
        final captured = verify(() => mockRepository.updateTask(captureAny())).captured;
        final capturedTask = captured.first as Task;
        expect(capturedTask.isCompleted, true);
      });

      test('should handle multiple task updates', () async {
        // Arrange
        final task1 = Task(
          id: '1',
          title: 'Updated Task 1',
          dueDate: DateTime(2024, 1, 15),
          isCompleted: true,
        );
        final task2 = Task(
          id: '2',
          title: 'Updated Task 2',
          dueDate: DateTime(2024, 1, 16),
          isCompleted: false,
        );
        
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(task1);
        await useCase.call(task2);

        // Assert
        verify(() => mockRepository.updateTask(task1)).called(1);
        verify(() => mockRepository.updateTask(task2)).called(1);
      });
    });

    group('Error Handling', () {
      test('should propagate repository exceptions', () async {
        // Arrange
        final exception = Exception('Update failed');
        when(() => mockRepository.updateTask(any()))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => useCase.call(testTask),
          throwsA(equals(exception)),
        );
        
        verify(() => mockRepository.updateTask(testTask)).called(1);
      });

      test('should handle task not found errors', () async {
        // Arrange
        when(() => mockRepository.updateTask(any()))
            .thenThrow(StateError('Task not found'));

        // Act & Assert
        expect(
          () => useCase.call(testTask),
          throwsA(isA<StateError>()),
        );
      });

      test('should handle repository timeout errors', () async {
        // Arrange
        when(() => mockRepository.updateTask(any()))
            .thenThrow(TimeoutException('Request timeout', Duration(seconds: 30)));

        // Act & Assert
        expect(
          () => useCase.call(testTask),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('should handle invalid task data gracefully', () async {
        // Arrange
        when(() => mockRepository.updateTask(any()))
            .thenThrow(ArgumentError('Invalid task data'));

        // Act & Assert
        expect(
          () => useCase.call(testTask),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle task with updated title', () async {
        // Arrange
        final updatedTask = Task(
          id: testTask.id,
          title: 'Updated Title',
          dueDate: testTask.dueDate,
          isCompleted: testTask.isCompleted,
        );
        
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(updatedTask);

        // Assert
        final captured = verify(() => mockRepository.updateTask(captureAny())).captured;
        final capturedTask = captured.first as Task;
        expect(capturedTask.title, 'Updated Title');
        expect(capturedTask.id, testTask.id);
      });

      test('should handle task with updated due date', () async {
        // Arrange
        final newDueDate = DateTime(2025, 6, 15);
        final updatedTask = Task(
          id: testTask.id,
          title: testTask.title,
          dueDate: newDueDate,
          isCompleted: testTask.isCompleted,
        );
        
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(updatedTask);

        // Assert
        final captured = verify(() => mockRepository.updateTask(captureAny())).captured;
        final capturedTask = captured.first as Task;
        expect(capturedTask.dueDate, newDueDate);
        expect(capturedTask.id, testTask.id);
      });

      test('should handle task completion toggle', () async {
        // Arrange
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act - Mark as completed
        testTask.isCompleted = true;
        await useCase.call(testTask);
        
        // Act - Mark as incomplete
        testTask.isCompleted = false;
        await useCase.call(testTask);

        // Assert
        verify(() => mockRepository.updateTask(testTask)).called(2);
      });

      test('should handle task with very long updated title', () async {
        // Arrange
        final longTitle = 'A' * 5000;
        final updatedTask = Task(
          id: testTask.id,
          title: longTitle,
          dueDate: testTask.dueDate,
          isCompleted: testTask.isCompleted,
        );
        
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(updatedTask);

        // Assert
        final captured = verify(() => mockRepository.updateTask(captureAny())).captured;
        final capturedTask = captured.first as Task;
        expect(capturedTask.title.length, 5000);
      });

      test('should handle task with past due date update', () async {
        // Arrange
        final pastDate = DateTime(2020, 1, 1);
        final updatedTask = Task(
          id: testTask.id,
          title: testTask.title,
          dueDate: pastDate,
          isCompleted: testTask.isCompleted,
        );
        
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(updatedTask);

        // Assert
        final captured = verify(() => mockRepository.updateTask(captureAny())).captured;
        final capturedTask = captured.first as Task;
        expect(capturedTask.dueDate, pastDate);
      });

      test('should handle task with future due date update', () async {
        // Arrange
        final futureDate = DateTime(2030, 12, 31);
        final updatedTask = Task(
          id: testTask.id,
          title: testTask.title,
          dueDate: futureDate,
          isCompleted: testTask.isCompleted,
        );
        
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(updatedTask);

        // Assert
        final captured = verify(() => mockRepository.updateTask(captureAny())).captured;
        final capturedTask = captured.first as Task;
        expect(capturedTask.dueDate, futureDate);
      });

      test('should handle empty title update', () async {
        // Arrange
        final updatedTask = Task(
          id: testTask.id,
          title: '',
          dueDate: testTask.dueDate,
          isCompleted: testTask.isCompleted,
        );
        
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(updatedTask);

        // Assert
        final captured = verify(() => mockRepository.updateTask(captureAny())).captured;
        final capturedTask = captured.first as Task;
        expect(capturedTask.title, '');
      });
    });

    group('Data Integrity', () {
      test('should preserve task ID during update', () async {
        // Arrange
        const originalId = '123';
        final updatedTask = Task(
          id: originalId,
          title: 'Completely New Title',
          dueDate: DateTime(2025, 12, 31),
          isCompleted: true,
        );
        
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(updatedTask);

        // Assert
        final captured = verify(() => mockRepository.updateTask(captureAny())).captured;
        final capturedTask = captured.first as Task;
        expect(capturedTask.id, originalId);
      });

      test('should handle concurrent updates correctly', () async {
        // Arrange
        when(() => mockRepository.updateTask(any()))
            .thenAnswer((_) async {});

        // Act - Simulate concurrent updates
        final futures = <Future>[];
        for (int i = 0; i < 10; i++) {
          final updatedTask = Task(
            id: testTask.id,
            title: 'Update $i',
            dueDate: testTask.dueDate.add(Duration(days: i)),
            isCompleted: i % 2 == 0,
          );
          futures.add(useCase.call(updatedTask));
        }
        
        await Future.wait(futures);

        // Assert
        verify(() => mockRepository.updateTask(any())).called(10);
      });
    });

    tearDown(() {
      reset(mockRepository);
    });
  });
}

