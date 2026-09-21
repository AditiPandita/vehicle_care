import 'package:flutter/material.dart';

import '../../app/theme.dart';

class OnboardingScreen extends StatefulWidget {
  final Future<void> Function(String name) onNameSaved;

  const OnboardingScreen({
    super.key,
    required this.onNameSaved,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController _nameController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await widget.onNameSaved(name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 40,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 80,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    size: 54,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 30),

                // Welcome Text
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.secondaryText,
                  ),
                ),

                const SizedBox(height: 4),

                const Text(
                  'VehicleCare',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                    letterSpacing: -0.8,
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'Keep all your vehicles organized\nin one place.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: AppTheme.secondaryText,
                  ),
                ),

                const SizedBox(height: 48),

                // Name Label
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What should we call you?',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.darkText,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Name Field
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _continue(),
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                    prefixIcon: Icon(
                      Icons.person_outline_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _continue,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Continue'),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}