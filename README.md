# SLA Task Tracker

SLA Task Tracker is a Flutter application for creating, organizing, and monitoring project tasks against service-level deadlines. It provides a task-focused workspace for the Atlas development team, including priority, assignee, status, deadline, and SLA risk information.

## Features

- Create tasks with a title, description, project, assignee, priority, status, start date, and deadline.
- Edit task details and validate required fields before saving.
- Search tasks by title or assignee.
- Filter tasks by status or overdue SLA state.
- Sort tasks by newest or oldest creation date.
- Display SLA state using the following rules:
  - **Completed**: the task is complete.
  - **Overdue**: the task is incomplete and its deadline has passed.
  - **At Risk**: the task is incomplete and due within 24 hours.
  - **On Track**: the task is more than 24 hours from its deadline.
- Persist tasks locally on the device using `shared_preferences`.
- Provide a profile view with editable user information and task progress.

## Technology Stack

- [Flutter](https://flutter.dev/)
- Dart 3.13.2 or later, before Dart 4.0.0
- Material 3 widgets
- `shared_preferences` for local task storage
- `sqflite` and `path` for database support
- `intl` for date and time utilities

## Requirements

Before running the project, install:

- Flutter SDK
- Dart SDK compatible with the version constraint in `pubspec.yaml`
- An Android emulator/device, iOS simulator/device, desktop target, or web browser

Check your Flutter installation with:

```bash
flutter doctor
```

## Getting Started

Clone the repository:

```bash
git clone https://github.com/Nnamdi004/SLA_task_tacker-Group_7.git
cd SLA_task_tacker-Group_7
```

Install the project dependencies:

```bash
flutter pub get
```

List the available devices:

```bash
flutter devices
```

Run the application:

```bash
flutter run -d <device-id>
```

To run the application in Chrome:

```bash
flutter run -d chrome
```

## Testing

Run the Flutter test suite:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

## Project Structure

```text
lib/
  main.dart                    Application entry point and theme
  models/                      Shared task model definitions
  database/                    SQLite database helper
  state/                       Application state and local persistence
  screens/                     Application screens and navigation
  widgets/                     Reusable task form widgets

test/                          Flutter widget tests
android/                       Android platform project
ios/                           iOS platform project
linux/                         Linux platform project
macos/                         macOS platform project
web/                           Web platform project
windows/                       Windows platform project
```

## Data and Persistence

Tasks are loaded when the application starts and saved locally as JSON through `SharedPreferences`.

Data is stored on the device and is not synchronized with a remote server or shared between users. Clearing the application data removes the locally stored task list.

The project also contains a `DatabaseHelper` for SQLite-backed task storage. The active startup flow currently uses `TaskStore` and `SharedPreferences`; the SQLite helper is available for a future persistence migration.

## Current Status

The task-list workflow is the primary implemented flow. The application shell also includes Dashboard, Team, and Profile destinations.

Profile components are present, while some shell destinations and task details/filter actions still contain placeholder or in-progress UI and are intended to be completed as the project evolves.

## AI Usage Declaration

AI tools were used for assistance during development and documentation. The project team is responsible for reviewing, testing, verifying, and understanding all submitted code.

## Contributing

1. Create a feature branch.
2. Make a focused change.
3. Run `flutter analyze` and `flutter test`.
4. Open a pull request describing the change and how it was verified.
