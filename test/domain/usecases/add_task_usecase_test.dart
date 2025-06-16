import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:interview_1/domain/model/task.dart';
import 'package:interview_1/domain/repositories/task_repository.dart';
import 'package:interview_1/domain/usecases/add_task_usecase.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  group('AddTaskUseCase Tests', () {
    late AddTaskUseCase useCase;
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
      useCase = AddTaskUseCase(mockRepository);
      testTask = Task(
        id: '123',
        title: 'Test Task',
        dueDate: DateTime(2024, 1, 15),
        isCompleted: false,
      );
    });

    group('Successful Operations', () {
      test('should add task successfully when repository call succeeds', () async {
        // Arrange
        when(() => mockRepository.addTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(testTask);

        // Assert
        verify(() => mockRepository.addTask(testTask)).called(1);
      });

      test('should call repository with correct task data', () async {
        // Arrange
        when(() => mockRepository.addTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(testTask);

        // Assert
        final captured = verify(() => mockRepository.addTask(captureAny())).captured;
        final capturedTask = captured.first as Task;
        
        expect(capturedTask.id, testTask.id);
        expect(capturedTask.title, testTask.title);
        expect(capturedTask.dueDate, testTask.dueDate);
        expect(capturedTask.isCompleted, testTask.isCompleted);
      });

      test('should handle multiple task additions', () async {
        // Arrange
        final task1 = Task(
          id: '1',
          title: 'Task 1',
          dueDate: DateTime(2024, 1, 15),
          isCompleted: false,
        );
        final task2 = Task(
          id: '2',
          title: 'Task 2',
          dueDate: DateTime(2024, 1, 16),
          isCompleted: true,
        );
        
        when(() => mockRepository.addTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(task1);
        await useCase.call(task2);

        // Assert
        verify(() => mockRepository.addTask(task1)).called(1);
        verify(() => mockRepository.addTask(task2)).called(1);
      });
    });

    group('Error Handling', () {
      test('should propagate repository exceptions', () async {
        // Arrange
        final exception = Exception('Database error');
        when(() => mockRepository.addTask(any()))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => useCase.call(testTask),
          throwsA(equals(exception)),
        );
        
        verify(() => mockRepository.addTask(testTask)).called(1);
      });

      test('should handle repository timeout errors', () async {
        // Arrange
        when(() => mockRepository.addTask(any()))
            .thenThrow(TimeoutException('Request timeout', Duration(seconds: 30)));

        // Act & Assert
        expect(
          () => useCase.call(testTask),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('should handle invalid task data gracefully', () async {
        // Arrange
        final invalidTask = Task(
          id: '',
          title: '',
          dueDate: DateTime(2024, 1, 15),
          isCompleted: false,
        );
        
        when(() => mockRepository.addTask(any()))
            .thenThrow(ArgumentError('Invalid task data'));

        // Act & Assert
        expect(
          () => useCase.call(invalidTask),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Edge Cases', () {
      test('should handle task with future due date', () async {
        // Arrange
        final futureTask = Task(
          id: '123',
          title: 'Future Task',
          dueDate: DateTime(2030, 12, 31),
          isCompleted: false,
        );
        
        when(() => mockRepository.addTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(futureTask);

        // Assert
        verify(() => mockRepository.addTask(futureTask)).called(1);
      });

      test('should handle task with past due date', () async {
        // Arrange
        final pastTask = Task(
          id: '123',
          title: 'Past Task',
          dueDate: DateTime(2020, 1, 1),
          isCompleted: false,
        );
        
        when(() => mockRepository.addTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(pastTask);

        // Assert
        verify(() => mockRepository.addTask(pastTask)).called(1);
      });

      test('should handle already completed task', () async {
        // Arrange
        final completedTask = Task(
          id: '123',
          title: 'Completed Task',
          dueDate: DateTime(2024, 1, 15),
          isCompleted: true,
        );
        
        when(() => mockRepository.addTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(completedTask);

        // Assert
        verify(() => mockRepository.addTask(completedTask)).called(1);
      });

      test('should handle very long task title', () async {
        // Arrange
        final longTitleTask = Task(
          id: '123',
          title: 'A' * 1000,
          dueDate: DateTime(2024, 1, 15),
          isCompleted: false,
        );
        
        when(() => mockRepository.addTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(longTitleTask);

        // Assert
        verify(() => mockRepository.addTask(longTitleTask)).called(1);
      });
    });

    tearDown(() {
      reset(mockRepository);
    });
  });
}

