// lib/main.dart
import 'package:flutter/material.dart';
import 'package:water_drop_nav_bar/water_drop_nav_bar.dart';
import 'screens/qr_validation_screen.dart';
import 'screens/uin_validation_screen.dart';

void main() {
  runApp(const MRZVerificationApp());
}

class MRZVerificationApp extends StatelessWidget {
  const MRZVerificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MRZ Verification',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const QrValidationScreen(),
    const UinValidationScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MRZ Certificate Validation 🛡️'),
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe between screens
        children: _screens,
      ),
      bottomNavigationBar: WaterDropNavBar(
        backgroundColor: Colors.white,
        onItemSelected: onItemSelected,
        selectedIndex: _selectedIndex,
        barItems: <BarItem>[
          BarItem(
            filledIcon: Icons.qr_code_scanner_rounded,
            outlinedIcon: Icons.qr_code_scanner_outlined,
          ),
          BarItem(
            filledIcon: Icons.fingerprint,
            outlinedIcon: Icons.fingerprint_outlined,
          ),
        ],
      ),
    );
  }
}