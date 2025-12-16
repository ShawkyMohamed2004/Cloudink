# CloudInk - Note Taking App 📝☁️

CloudInk is a beautiful and intuitive note-taking application built with Flutter. Store your ideas, thoughts, and important notes in a clean and organized interface.

## Features ✨

- **Beautiful Splash Screen** - Welcoming animation with CloudInk logo
- **User Authentication** - Login and Sign up functionality
- **Create Notes** - Add notes with custom titles and descriptions
- **Color Coding** - Choose from 4 beautiful colors for your notes (Blue, Red, Purple, Green)
- **Edit Notes** - Tap on any note to edit its content
- **Delete Notes** - Easy note deletion with confirmation dialog
- **Local Storage** - All notes are stored locally using SharedPreferences
- **Responsive Design** - Clean and modern UI that works great on all devices

## Screenshots 📱

The app includes:
- Splash screen with animated CloudInk logo
- Login/Signup screens with form validation
- Home screen displaying all notes in a beautiful card layout
- Add/Edit note screen with color selection
- Smooth navigation and animations

## Technology Stack 🛠️

- **Flutter** - Cross-platform mobile development framework
- **Dart** - Programming language
- **SharedPreferences** - Local data storage
- **UUID** - Unique identifier generation
- **Intl** - Date formatting

## Dependencies 📦

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.0.15
  uuid: ^3.0.7
  intl: ^0.19.0
```

## Getting Started 🚀

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd CloudInk
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## App Structure 📁

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── note.dart            # Note data model
├── screens/
│   ├── splash_screen.dart   # Splash screen with animation
│   ├── login_screen.dart    # User login interface
│   ├── signup_screen.dart   # User registration interface
│   ├── home_screen.dart     # Main notes display
│   └── add_note_screen.dart # Note creation/editing
└── services/
    └── notes_service.dart   # Data management service
```

## Features in Detail 🔍

### Authentication
- Simple email/password validation
- Persistent login state
- Secure logout functionality

### Note Management
- Create notes with titles and descriptions
- Choose from 4 predefined colors
- Edit existing notes by tapping on them
- Delete notes with confirmation
- Automatic date tracking

### Data Storage
- Local storage using SharedPreferences
- JSON serialization for note data
- Persistent data across app sessions

## Design Principles 🎨

- **Material Design** - Following Google's design guidelines
- **Color Consistency** - Using a cohesive color scheme
- **User Experience** - Intuitive navigation and interactions
- **Accessibility** - Clear text and appropriate contrast ratios

## Color Scheme 🌈

- **Primary Blue**: #2196F3
- **Accent Gold**: #F5B041
- **Dark Blue**: #2C3E50
- **Light Gray**: #F5F5F5
- **Text Gray**: #7F8C8D

## Future Enhancements 🔮

- Cloud synchronization
- Rich text editing
- Note categories and tags
- Search functionality
- Export/Import features
- Dark mode support
- Reminder notifications

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

---

**CloudInk** - Your Ideas, Everywhere ☁️✨
