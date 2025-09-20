# School Exit Manager

A Flutter mobile application for managing student exit permissions using QR code scanning and Appwrite backend integration.

## Features

- **Authentication System**: Secure login with email/student ID and password
- **QR Code Scanning**: Real-time camera scanning with animated overlay
- **Manual Entry**: Fallback option for manual student ID input
- **Permission Checking**: Real-time validation against Appwrite database
- **Result Display**: Clear visual feedback for allowed/denied permissions
- **Offline Handling**: Graceful error handling for network issues
- **Responsive Design**: Clean, school-branded UI with smooth animations

## Screenshots

The app features a modern, clean interface with:
- Animated splash screen with school branding
- Secure authentication with form validation
- Intuitive home screen with prominent scan button
- Professional QR scanner with animated overlay
- Clear result screens with color-coded feedback

## Setup & Installation

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code with Flutter extensions
- Appwrite server instance

### 1. Clone the Repository

\`\`\`bash
git clone <repository-url>
cd school_exit_manager
\`\`\`

### 2. Install Dependencies

\`\`\`bash
flutter pub get
\`\`\`

### 3. Configure Environment Variables

Create a `.env` file in the root directory:

\`\`\`env
APPWRITE_ENDPOINT=https://[YOUR_APPWRITE_ENDPOINT]
APPWRITE_PROJECT_ID=[PROJECT_ID]
APPWRITE_COLLECTION_ID=[COLLECTION_ID]
\`\`\`

### 4. Configure Appwrite Project & Collection

#### Create Appwrite Project
1. Set up an Appwrite server instance
2. Create a new project in Appwrite console
3. Note down the project ID and endpoint

#### Create Students Collection
Create a collection named `students` with the following attributes:

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `studentId` | String | Yes | Unique student identifier (QR code value) |
| `name` | String | Yes | Student's full name |
| `allowed` | Boolean | Yes | Exit permission status |
| `description` | String | No | Additional notes or reason |
| `lastUpdated` | DateTime | No | Last modification timestamp |

#### Set Up Authentication
1. Enable Email/Password authentication in Appwrite console
2. Create user accounts for staff members who will use the app

### 5. Configure Platform Permissions

#### Android (android/app/src/main/AndroidManifest.xml)
\`\`\`xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
\`\`\`

#### iOS (ios/Runner/Info.plist)
\`\`\`xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes for student exit management.</string>
\`\`\`

### 6. Run the Application

\`\`\`bash
# Debug mode
flutter run

# Release mode
flutter run --release
\`\`\`

## How to Use

### For Staff Members

1. **Login**: Use your assigned email and password to authenticate
2. **Scan QR Codes**: Tap "Scan QR Code" on the home screen
3. **Manual Entry**: Use the keyboard icon to manually enter student IDs
4. **View Results**: See immediate feedback on student exit permissions
5. **Logout**: Use the logout button in the top-right corner

### For Administrators

1. **Manage Students**: Add/update student records in Appwrite console
2. **Set Permissions**: Toggle the `allowed` field for each student
3. **Monitor Usage**: Check Appwrite logs for scan activity
4. **Update Information**: Modify student names and descriptions as needed

## Testing

Run the test suite:

\`\`\`bash
flutter test
\`\`\`

The test suite includes:
- Authentication flow validation
- Navigation testing
- UI component verification
- Error handling scenarios

## Project Structure

\`\`\`
lib/
├── main.dart                 # App entry point
├── screens/
│   ├── splash_screen.dart    # Initial loading screen
│   ├── auth_screen.dart      # Login interface
│   ├── home_screen.dart      # Main dashboard
│   ├── scan_screen.dart      # QR scanning interface
│   └── result_screen.dart    # Permission result display
├── services/
│   └── appwrite_service.dart # Backend integration
└── widgets/
    └── qr_overlay.dart       # Animated scan overlay

test/
└── widget_test.dart          # Unit and widget tests

assets/
└── logo.png                  # App logo placeholder
\`\`\`

## Architecture

The app follows a clean architecture pattern:

- **Provider Pattern**: State management using Flutter Provider
- **Service Layer**: Centralized Appwrite integration
- **Screen Components**: Modular UI screens with clear responsibilities
- **Custom Widgets**: Reusable components like the QR overlay
- **Error Handling**: Comprehensive error management with user feedback

## Dependencies

### Core Dependencies
- `flutter`: Flutter SDK
- `provider`: State management
- `appwrite`: Backend integration
- `qr_code_scanner`: QR code scanning
- `permission_handler`: Camera permissions
- `flutter_secure_storage`: Secure session storage
- `flutter_dotenv`: Environment configuration
- `intl`: Date/time formatting

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Code quality rules

## Troubleshooting

### Common Issues

**Camera Permission Denied**
- Ensure camera permissions are properly configured in platform files
- Check device settings to verify app has camera access

**Appwrite Connection Failed**
- Verify `.env` file configuration
- Check network connectivity
- Confirm Appwrite server is accessible

**QR Scanning Not Working**
- Test camera functionality in device camera app
- Ensure QR codes contain valid student IDs
- Check lighting conditions for scanning

**Authentication Errors**
- Verify user accounts exist in Appwrite
- Check email/password combinations
- Confirm authentication is enabled in Appwrite project

### Performance Optimization

- The app uses efficient state management with Provider
- QR scanning is optimized to prevent multiple simultaneous scans
- Network requests include proper error handling and timeouts
- UI animations are lightweight and performant

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For technical support or questions:
1. Check the troubleshooting section above
2. Review Appwrite documentation
3. Submit an issue in the project repository
