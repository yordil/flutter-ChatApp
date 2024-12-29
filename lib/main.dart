import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/user_list_page.dart';
import 'pages/chat_box_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './helper/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const MyApp());
  } catch (error) {
    runApp(ErrorApp(errorMessage: error.toString()));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationProvider = NotificationProvider();
    notificationProvider
        .setupOnlineStatusListener(); // Start listening to auth state changes

    return MaterialApp(
      title: 'YO Chat App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 16),
        ),
      ),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignupPage());
          case '/userlist':
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              // Pass the current user's ID to UserListPage
              return MaterialPageRoute(
                builder: (_) => UserListPage(currentUserId: currentUser.uid),
              );
            } else {
              return MaterialPageRoute(builder: (_) => const LoginPage());
            }
          case '/chatbox':
            // Extract the arguments for ChatBoxPage
            final args = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (_) => ChatBoxPage(receiverId: args ?? ''),
            );
          case '/logout':
            // Handle logout and update online status
            notificationProvider.setOnlineStatus(false); // Set user as offline
            return MaterialPageRoute(builder: (_) => const LoginPage());
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: const Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String errorMessage;

  const ErrorApp({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              errorMessage,
              style: const TextStyle(fontSize: 18, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
