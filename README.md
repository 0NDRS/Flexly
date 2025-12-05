# Flexly

A comprehensive mobile application built with Flutter and a Node.js backend.

## Getting Started

To run this project locally, you need to set up both the backend server and the Flutter mobile application.

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js](https://nodejs.org/) (v14 or higher)

### 1. Backend Setup

The backend is located in the `backend/` directory and is built with Node.js, Express, and MongoDB.

1. Navigate to the backend directory:

    ```bash
    cd backend
    ```

2. Install the necessary dependencies:

    ```bash
    npm install
    ```

3. **Environment Configuration (.env)**:
    The backend requires a `.env` file containing database connection strings (MongoDB URI) and JWT secrets.
    > **Note:** For security reasons, the `.env` file is not included in the repository. **Please contact the development team to obtain the `.env` file for testing purposes.**

4. Start the backend server:

    ```bash
    npm start
    ```

    The server will start running on `http://localhost:3000`.

### 2. Mobile App Setup

Once the backend is running, you can start the Flutter application.

1. Return to the project root directory:

    ```bash
    cd ..
    ```

2. Install Flutter dependencies:

    ```bash
    flutter pub get
    ```

3. Run the app on your preferred emulator or device:

    ```bash
    flutter run
    ```

    *Note: The app is configured to connect to `10.0.2.2:3000` for Android emulators and `localhost:3000` for iOS simulators.*

## Project Structure

```text
flexly/
├── android/          # Android-specific native code
├── ios/              # iOS-specific native code
├── lib/              # Flutter/Dart source files
│   ├── main.dart     # Application entry point
│   ├── pages/        # UI Screens (Login, Register, Home, etc.)
│   ├── services/     # Business logic and API calls
│   └── theme/        # App styling and colors
├── backend/          # Node.js Backend
│   ├── src/          # Backend source code
│   ├── package.json  # Backend dependencies
│   └── ...
├── test/             # Unit and Widget tests
├── pubspec.yaml      # Flutter dependencies
└── README.md         # Project documentation
```

## Testing

To run the Flutter tests:

```bash
flutter test
```
