import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:interview_1/domain/model/task.dart';
import 'package:interview_1/data/datasources/hive_datasource.dart';
import 'package:interview_1/data/repositories/task_repository_impl.dart';

class MockHiveDataSource extends Mock implements HiveDataSource {}

void main() {
  group('TaskRepositoryImpl Tests', () {
    late TaskRepositoryImpl repository;
    late MockHiveDataSource mockDataSource;
    late Task testTask;
    late List<Task> sampleTasks;

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
      mockDataSource = MockHiveDataSource();
      repository = TaskRepositoryImpl(mockDataSource);
      
      testTask = Task(
        id: '123',
        title: 'Test Task',
        dueDate: DateTime(2024, 1, 15),
        isCompleted: false,
      );
      
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
      ];
    });

    group('Add Task', () {
      test('should call data source addTask method', () async {
        // Arrange
        when(() => mockDataSource.addTask(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.addTask(testTask);

        // Assert
        verify(() => mockDataSource.addTask(testTask)).called(1);
      });

      test('should propagate data source exceptions', () async {
        // Arrange
        final exception = Exception('Data source error');
        when(() => mockDataSource.addTask(any()))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.addTask(testTask),
          throwsA(equals(exception)),
        );
      });
    });

    group('Get Tasks', () {
      test('should return tasks from data source', () async {
        // Arrange
        when(() => mockDataSource.getTasks())
            .thenAnswer((_) async => sampleTasks);

        // Act
        final result = await repository.getTasks();

        // Assert
        expect(result, equals(sampleTasks));
        verify(() => mockDataSource.getTasks()).called(1);
      });

      test('should return empty list when no tasks exist', () async {
        // Arrange
        when(() => mockDataSource.getTasks())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getTasks();

        // Assert
        expect(result, isEmpty);
        verify(() => mockDataSource.getTasks()).called(1);
      });

      test('should propagate data source exceptions', () async {
        // Arrange
        final exception = Exception('Data source error');
        when(() => mockDataSource.getTasks())
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.getTasks(),
          throwsA(equals(exception)),
        );
      });
    });

    group('Update Task', () {
      test('should call data source updateTask method', () async {
        // Arrange
        when(() => mockDataSource.updateTask(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.updateTask(testTask);

        // Assert
        verify(() => mockDataSource.updateTask(testTask)).called(1);
      });

      test('should propagate data source exceptions', () async {
        // Arrange
        final exception = Exception('Update failed');
        when(() => mockDataSource.updateTask(any()))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.updateTask(testTask),
          throwsA(equals(exception)),
        );
      });
    });

    group('Delete Task', () {
      test('should call data source deleteTask method with correct ID', () async {
        // Arrange
        const taskId = '123';
        when(() => mockDataSource.deleteTask(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteTask(taskId);

        // Assert
        verify(() => mockDataSource.deleteTask(taskId)).called(1);
      });

      test('should propagate data source exceptions', () async {
        // Arrange
        const taskId = '123';
        final exception = Exception('Delete failed');
        when(() => mockDataSource.deleteTask(any()))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => repository.deleteTask(taskId),
          throwsA(equals(exception)),
        );
      });
    });

    group('Integration Scenarios', () {
      test('should handle multiple operations in sequence', () async {
        // Arrange
        when(() => mockDataSource.addTask(any()))
            .thenAnswer((_) async {});
        when(() => mockDataSource.getTasks())
            .thenAnswer((_) async => sampleTasks);
        when(() => mockDataSource.updateTask(any()))
            .thenAnswer((_) async {});
        when(() => mockDataSource.deleteTask(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.addTask(testTask);
        final tasks = await repository.getTasks();
        await repository.updateTask(testTask);
        await repository.deleteTask(testTask.id);

        // Assert
        expect(tasks, equals(sampleTasks));
        verify(() => mockDataSource.addTask(testTask)).called(1);
        verify(() => mockDataSource.getTasks()).called(1);
        verify(() => mockDataSource.updateTask(testTask)).called(1);
        verify(() => mockDataSource.deleteTask(testTask.id)).called(1);
      });

      test('should handle concurrent operations', () async {
        // Arrange
        when(() => mockDataSource.addTask(any()))
            .thenAnswer((_) async {});

        // Act
        final futures = <Future>[];
        for (int i = 0; i < 5; i++) {
          final task = Task(
            id: 'task-$i',
            title: 'Task $i',
            dueDate: DateTime(2024, 1, 15 + i),
            isCompleted: false,
          );
          futures.add(repository.addTask(task));
        }
        
        await Future.wait(futures);

        // Assert
        verify(() => mockDataSource.addTask(any())).called(5);
      });
    });

    tearDown(() {
      reset(mockDataSource);
    });
  });
}

