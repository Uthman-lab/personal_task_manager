# TaskFlow

A modern task management application built with Flutter that helps you organize and track your tasks efficiently. TaskFlow features a clean architecture, background task monitoring, and a beautiful user interface.

## Features

- 📝 Create and manage tasks with due dates
- ✅ Mark tasks as complete/incomplete
- 🔄 Background task monitoring for overdue tasks
- 🎨 Modern and clean user interface
- 📱 Cross-platform support (Android, iOS, Web)
- 💾 Local storage using Hive
- 🔔 Automatic overdue task notifications (To do)

## Architecture

The project follows Clean Architecture principles with a clear separation of concerns:

```
lib/
├── core/           # Core functionality and services
│   └── services/   # Background services, utilities
├── data/           # Data layer
│   ├── repositories/
│   └── datasources/
├── domain/         # Business logic
│   ├── entities/
│   └── usecases/
└── presentation/   # UI layer
    ├── pages/      # Full screens
    └── widgets/    # Reusable UI components
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/taskflow.git
```

2. Navigate to the project directory:
```bash
cd taskflow
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Background Task Monitoring

TaskFlow uses the WorkManager package to monitor tasks in the background. The app checks for overdue tasks periodically and provides notifications when tasks are past their due date.

## Dependencies

- `flutter`: UI framework
- `hive`: Local storage
- `workmanager`: Background task management
- `flutter_lints`: Code quality and style

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Hive team for the efficient local storage solution
- WorkManager team for the background task management package
