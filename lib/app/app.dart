import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';

class VehicleCareApp extends StatefulWidget {
  const VehicleCareApp({super.key});

  @override
  State<VehicleCareApp> createState() => _VehicleCareAppState();
}

class _VehicleCareAppState extends State<VehicleCareApp> {
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final preferences = await SharedPreferences.getInstance();

    final savedName = preferences.getString('user_name');

    if (!mounted) {
      return;
    }

    setState(() {
      _userName = savedName;
      _isLoading = false;
    });
  }

  Future<void> _saveUserName(String name) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString('user_name', name);

    if (!mounted) {
      return;
    }

    setState(() {
      _userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VehicleCare',
      theme: AppTheme.lightTheme,
      home: _buildStartScreen(),
    );
  }

  Widget _buildStartScreen() {
    if (_isLoading) {
      return const LoadingScreen();
    }

    if (_userName == null || _userName!.isEmpty) {
      return OnboardingScreen(
        onNameSaved: _saveUserName,
      );
    }

    return HomeScreen(
      userName: _userName!,
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}