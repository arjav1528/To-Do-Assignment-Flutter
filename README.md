# 📱 Mini TaskHub – Personal Task Tracker

A modern, responsive Flutter application for personal task management with Supabase authentication and database integration. Built with clean architecture, state management, and beautiful UI/UX.

## ✨ Features

- 🔐 **Email/Password Authentication** via Supabase
- ✅ **Task Management**: Create, Read, Update, Delete tasks
- 🎨 **Beautiful UI**: Responsive design with Material Design 3
- 🌓 **Dark/Light Theme**: Toggle between themes with persistence
- 📱 **Responsive Design**: Works seamlessly across different screen sizes
- 🔄 **Swipe Gestures**: 
  - Swipe right → Update task
  - Swipe left → Delete task
- ✅ **Task Status Toggle**: Mark tasks as pending/completed
- 🔔 **Real-time State Management**: Using Provider pattern
- 📝 **Comprehensive Logging**: Built-in logger for debugging

## 🎯 Project Structure

```
lib/
├── main.dart
├── app/
│   └── theme.dart              # App theme configuration
├── auth/
│   ├── login_screen.dart       # Login screen
│   ├── signup_screen.dart      # Sign up screen
│   └── auth_service.dart       # Authentication service
├── dashboard/
│   ├── dashboard_screen.dart   # Main dashboard
│   ├── add_task_bottom_sheet.dart    # Add task UI
│   └── update_task_bottom_sheet.dart  # Update task UI
├── models/
│   └── task_model.dart         # Task data model
├── services/
│   ├── supabase_service.dart   # Supabase initialization
│   ├── task_service.dart       # Task CRUD operations
│   └── theme_service.dart      # Theme management
└── utils/
    ├── validators.dart         # Form validation
    └── app_logger.dart         # Logging utility
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Supabase account and project
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd todo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   
   Create a `.env` file in the root directory:
   ```bash
   touch .env
   ```
   
   Add your Supabase credentials:
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```
   
   > **Note**: Get these credentials from your Supabase project settings: https://app.supabase.com/project/_/settings/api

4. **Set up Supabase Database**
   
   Run the following SQL script in your Supabase SQL Editor:

   ```sql
   -- Create tasks table
   CREATE TABLE IF NOT EXISTS tasks (
     id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
     user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
     title TEXT NOT NULL,
     status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed')),
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
   );

   -- Create indexes for performance
   CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id);
   CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
   CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at DESC);

   -- Enable Row Level Security
   ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

   -- Create RLS Policies
   CREATE POLICY "Users can view their own tasks"
     ON tasks FOR SELECT
     USING (auth.uid() = user_id);

   CREATE POLICY "Users can insert their own tasks"
     ON tasks FOR INSERT
     WITH CHECK (auth.uid() = user_id);

   CREATE POLICY "Users can update their own tasks"
     ON tasks FOR UPDATE
     USING (auth.uid() = user_id)
     WITH CHECK (auth.uid() = user_id);

   CREATE POLICY "Users can delete their own tasks"
     ON tasks FOR DELETE
     USING (auth.uid() = user_id);

   -- Create function for updated_at trigger
   CREATE OR REPLACE FUNCTION update_updated_at_column()
   RETURNS TRIGGER AS $$
   BEGIN
     NEW.updated_at = NOW();
     RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;

   -- Create trigger for updated_at
   CREATE TRIGGER update_tasks_updated_at
     BEFORE UPDATE ON tasks
     FOR EACH ROW
     EXECUTE FUNCTION update_updated_at_column();
   ```

5. **Configure Supabase Authentication**
   
   - Go to **Authentication** → **Settings** in Supabase Dashboard
   - For development, you can disable email confirmations (optional)
   - Configure redirect URLs if needed (see Supabase documentation)

6. **Run the app**
   ```bash
   flutter run
   ```

## 📖 Usage Guide

### Authentication

1. **Sign Up**
   - Tap "Sign Up" on the login screen
   - Enter your email and password
   - Account is created and you're automatically signed in (if email verification is disabled)

2. **Sign In**
   - Enter your email and password
   - Tap "Sign In"
   - You'll be redirected to the dashboard

3. **Sign Out**
   - Tap the logout icon in the dashboard app bar

### Task Management

1. **Add Task**
   - Tap the `+` floating action button
   - Enter task title
   - Select status (pending/completed)
   - Tap "Add Task"

2. **Update Task**
   - Swipe right on a task tile
   - Modify title or status in the bottom sheet
   - Tap "Update Task"

3. **Delete Task**
   - Swipe left on a task tile
   - Confirm deletion in the dialog

4. **Toggle Task Status**
   - Tap the status icon (circle/checkmark) on the left of a task
   - Task status toggles between pending and completed

5. **Refresh Tasks**
   - Pull down on the task list to refresh

### Theme Toggle

- Tap the theme icon (sun/moon) in the dashboard app bar
- Theme preference is saved and persists across app restarts

## 🔧 Hot Reload vs Hot Restart

### Hot Reload (⚡ Fast)
- **What it does**: Injects updated code into the running Dart VM without restarting the app
- **When to use**: 
  - UI changes (colors, text, layout)
  - Styling modifications
  - Most code changes
- **How to trigger**: 
  - Press `r` in the terminal
  - Click the hot reload button in your IDE
  - Save the file (if auto-save is enabled)
- **State preserved**: ✅ Yes - All app state is maintained
- **Speed**: Very fast (usually < 1 second)

**Example**: Change a button color → Hot Reload → See the change immediately

### Hot Restart (🔄 Complete Restart)
- **What it does**: Restarts the app completely, losing all state
- **When to use**: 
  - Changes to `main()` function
  - Adding/removing dependencies
  - Modifying initialization code
  - Changes to app-level providers
  - When Hot Reload doesn't work
- **How to trigger**: 
  - Press `R` (capital R) in the terminal
  - Click the hot restart button in your IDE
- **State preserved**: ❌ No - App restarts from scratch
- **Speed**: Slower (usually 2-5 seconds)

**Example**: 
- Modify Supabase initialization in `main.dart` → Hot Restart required
- Add a new Provider → Hot Restart required
- Change app theme configuration → Hot Restart required

### When to Use Which?

| Change Type | Hot Reload | Hot Restart |
|------------|------------|-------------|
| UI/Styling | ✅ | ❌ |
| Business Logic | ✅ | ❌ |
| `main()` function | ❌ | ✅ |
| Dependencies | ❌ | ✅ |
| Initialization | ❌ | ✅ |
| State Management Setup | ❌ | ✅ |

**Pro Tip**: If Hot Reload doesn't work or you see unexpected behavior, try Hot Restart first before debugging further.

## 🧪 Testing

### Running Tests

```bash
flutter test
```

### Test Coverage

- Task model serialization tests (to be added)
- Widget tests (to be added)

## 🏗️ Architecture

### State Management
- **Provider**: Used for state management
  - `AuthService`: Manages authentication state
  - `TaskService`: Manages task CRUD operations
  - `ThemeService`: Manages theme preferences

### Key Concepts Implemented

| Concept | Implementation |
|---------|---------------|
| **UI/UX** | Material Design 3, Responsive layouts |
| **Auth (Supabase)** | Email/password authentication |
| **State Management** | Provider pattern with ChangeNotifier |
| **DB (Supabase)** | PostgreSQL with Row Level Security |
| **Navigation** | Stream-based auth routing |
| **Async Programming** | Future/async-await for Supabase calls |
| **OOP & Functional** | Task model, service classes, validators |
| **Responsive Design** | flutter_screenutil for all screen sizes |
| **Animations** | Swipe gestures, transitions, loading indicators |
| **Custom Widgets** | Reusable TaskTile, bottom sheets |
| **Theming** | Light/dark theme with persistence |

## 📦 Dependencies

- `supabase_flutter: ^2.12.0` - Supabase integration
- `flutter_dotenv: ^6.0.0` - Environment variables
- `flutter_screenutil: ^5.9.0` - Responsive design
- `provider: ^6.1.1` - State management
- `logger: ^2.6.2` - Logging utility
- `shared_preferences: ^2.2.2` - Theme persistence

## 🔐 Security

- Row Level Security (RLS) enabled on tasks table
- Users can only access their own tasks
- Secure authentication via Supabase
- Environment variables for sensitive data

## 🎨 UI/UX Features

- **Responsive Design**: Adapts to all screen sizes
- **Material Design 3**: Modern, clean interface
- **Swipe Gestures**: Intuitive task management
- **Loading States**: Visual feedback during operations
- **Error Handling**: User-friendly error messages
- **Empty States**: Helpful messages when no tasks exist
- **Pull to Refresh**: Easy task list refresh

## 🚧 Future Enhancements

- [ ] Real-time updates using Supabase Realtime
- [ ] Task categories/tags
- [ ] Task due dates
- [ ] Task search and filtering
- [ ] Task sorting options
- [ ] Offline support
- [ ] Push notifications

## 🐛 Troubleshooting

### Common Issues

1. **Supabase initialization fails**
   - Check `.env` file exists and has correct credentials
   - Verify Supabase project is active
   - Check network connection

2. **Tasks not loading**
   - Verify database table is created
   - Check RLS policies are set up correctly
   - Ensure user is authenticated

3. **Theme not persisting**
   - Check SharedPreferences permissions
   - Verify ThemeService is properly initialized

4. **Swipe gestures not working**
   - Ensure Dismissible widget is properly configured
   - Check for conflicting gestures

## 📝 License

This project is for educational purposes.

## 👨‍💻 Development

### Code Style
- Follows Flutter/Dart style guidelines
- Uses `flutter_lints` for code quality
- Comprehensive logging for debugging

### Logging
The app uses a centralized logger (`AppLogger`) with different log levels:
- `success()` - Success operations
- `info()` - General information
- `warning()` - Warnings
- `error()` - Errors with stack traces
- `debug()` - Debug messages

## 📞 Support

For issues and questions, please open an issue in the repository.

---

**Built with ❤️ using Flutter and Supabase**
