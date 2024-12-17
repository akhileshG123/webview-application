import 'package:flutter/material.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:webview_application/widgets/screens/home_screen.dart';
import 'package:webview_application/widgets/screens/webview_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WebViewScreen(),
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: FluidNavBar(
        icons: [
          FluidNavBarIcon(icon: Icons.home, extras: {"label": "Home"}),
          FluidNavBarIcon(icon: Icons.games, extras: {"label": "Platforms"}),
        ],
        onChange: _onItemSelected,
        style: const FluidNavBarStyle(
          iconSelectedForegroundColor: Colors.white,
          iconUnselectedForegroundColor: Colors.black,
          barBackgroundColor: Color.fromARGB(255, 71, 69, 69),
        ),
        scaleFactor: 1.5,
        defaultIndex: _selectedIndex,
      ),
    );
  }
}


