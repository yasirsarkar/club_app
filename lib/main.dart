// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/member_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/donation_provider.dart';
import 'providers/subscription_plan_provider.dart';
import 'providers/dues_provider.dart'; // <-- নতুন DuesProvider ইম্পোর্ট
import 'providers/notice_provider.dart';

import 'screens/login_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/accountant_dashboard_screen.dart';
import 'screens/member_dashboard_screen.dart';
import 'screens/pending_approval_screen.dart';
import 'screens/suspended_account_screen.dart';
import 'screens/complete_profile_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => DonationProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionPlanProvider()),
        ChangeNotifierProvider(create: (_) => DuesProvider()), // <-- এই লাইনটি যোগ করা হয়েছে
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Club Management',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoggedIn) {
      final user = authProvider.user;
      if (user == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (user.status == 'Pending') {
        return const PendingApprovalScreen();
      }
      if (user.status == 'Suspended') {
        return const SuspendedAccountScreen();
      }

      if (user.phone == null || user.phone!.isEmpty) {
        return const CompleteProfileScreen();
      }

      switch (user.role) {
        case 'Admin':
          return const AdminDashboardScreen();
        case 'Accountant':
          return const AccountantDashboardScreen();
        case 'General Member':
          return const MemberDashboardScreen();
        default:
          WidgetsBinding.instance.addPostFrameCallback((_) {
            authProvider.signOut();
          });
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    } else {
      return const LoginScreen();
    }
  }
}