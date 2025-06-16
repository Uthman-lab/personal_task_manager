import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:interview_1/domain/repositories/task_repository.dart';
import 'package:interview_1/domain/usecases/delete_task_usecase.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
  group('DeleteTaskUseCase Tests', () {
    late DeleteTaskUseCase useCase;
    late MockTaskRepository mockRepository;
    const String testTaskId = '123';

    setUp(() {
      mockRepository = MockTaskRepository();
      useCase = DeleteTaskUseCase(mockRepository);
    });

    group('Successful Operations', () {
      test('should delete task successfully when repository call succeeds', () async {
        // Arrange
        when(() => mockRepository.deleteTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(testTaskId);

        // Assert
        verify(() => mockRepository.deleteTask(testTaskId)).called(1);
      });

      test('should call repository with correct task ID', () async {
        // Arrange
        when(() => mockRepository.deleteTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(testTaskId);

        // Assert
        final captured = verify(() => mockRepository.deleteTask(captureAny())).captured;
        expect(captured.first, testTaskId);
      });

      test('should handle multiple task deletions', () async {
        // Arrange
        const taskId1 = 'task-1';
        const taskId2 = 'task-2';
        const taskId3 = 'task-3';
        
        when(() => mockRepository.deleteTask(any()))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(taskId1);
        await useCase.call(taskId2);
        await useCase.call(taskId3);

        // Assert
        verify(() => mockRepository.deleteTask(taskId1)).called(1);
        verify(() => mockRepository.deleteTask(taskId2)).called(1);
        verify(() => mockRepository.deleteTask(taskId3)).called(1);
      });
    });

    group('Error Handling', () {
      test('should propagate repository exceptions', () async {
        // Arrange
        final exception = Exception('Delete operation failed');
        when(() => mockRepository.deleteTask(any()))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => useCase.call(testTaskId),
          throwsA(equals(exception)),
        );
      });

      test('should handle task not found errors', () async {
        // Arrange
        when(() => mockRepository.deleteTask(any()))
            .thenThrow(StateError('Task not found'));

        // Act & Assert
        expect(
          () => useCase.call(testTaskId),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}

