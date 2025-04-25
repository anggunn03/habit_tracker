import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/page/login_page.dart';
import 'package:habit_tracker/page/habit_page.dart';

Future<void> main() async {
  await Supabase.initialize(url: 'SUPAhttps://zyjcucjmurzhnxdrzcbt.supabase.co', anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp5amN1Y2ptdXJ6aG54ZHJ6Y2J0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyMTk5NTIsImV4cCI6MjA2MDc5NTk1Mn0.s-NdEi8KuQ3wmFXFElSL69yCeQFGFF2goSKGb5ty4EU');
  runApp(const MyApp());
} 

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Supabase.instance.client.auth.currentUser == null
          ? const LoginPage()
          : const HabitTrackerPage(),
    );
  }
}

