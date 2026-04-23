import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/route_constants.dart';
import '../../providers/settings_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<SettingsProvider>().load();
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pushReplacementNamed(context, Routes.home);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF1B5E20),
    body: const Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.eco, size: 80, color: Colors.white),
        SizedBox(height: 16),
        Text('Plant DD AI',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('AI-powered crop disease detection',
            style: TextStyle(color: Color(0xFFA5D6A7), fontSize: 14)),
        SizedBox(height: 40),
        CircularProgressIndicator(color: Colors.white),
      ]),
    ),
  );
}
