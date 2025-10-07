import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// আপনার মডেল এবং প্রোভাইডার ফাইলের সঠিক পাথ দিন
import 'models/user_model.dart';
import 'providers/member_provider.dart';

// আপনার স্ক্রিন ফাইলের সঠিক পাথ দিন
import 'screens/login_screen.dart';
import 'screens/member_list_screen.dart';

// Firebase CLI দ্বারা তৈরি হওয়া ফাইল
import 'firebase_options.dart';

Future<void> main() async {
  // নিশ্চিত করে যে Flutter engine প্রস্তুত
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase শুধুমাত্র একবার চালু করা হচ্ছে
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ClubApp());
}

class ClubApp extends StatelessWidget {
  const ClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemberProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Club Management',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LoginWrapper(),
      ),
    );
  }
}

class LoginWrapper extends StatefulWidget {
  const LoginWrapper({super.key});
  @override
  State<LoginWrapper> createState() => _LoginWrapperState();
}

class _LoginWrapperState extends State<LoginWrapper> {
  Role? loggedInRole;

  @override
  Widget build(BuildContext context) {
    if (loggedInRole == null) {
      return LoginScreen(onLogin: (role) {
        setState(() {
          loggedInRole = role;
        });
      });
    } else {
      return const MemberListScreen();
    }
  }
}