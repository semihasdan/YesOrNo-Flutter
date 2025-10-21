import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:yes_or_no/screens/game_screen.dart';
import 'package:yes_or_no/screens/marketplace_screen.dart';
import 'package:yes_or_no/screens/profile_screen.dart';
import '../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _screens = [
    const GameScreen(),
    const MarketplaceScreen(),
    const ProfileScreen(),
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              Color(0xFF2A2A3A), // Brighter center
              AppColors.backgroundDark, // Darker edge
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: PageView(
          controller: _pageController,
          children: _screens,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.gamepad, size: 30, color: Colors.white),
          Icon(Icons.store, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        color: AppColors.backgroundDark2,
        buttonBackgroundColor: AppColors.primaryCyan,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: _onBottomNavTap,
        letIndexChange: (index) => true,
      ),
    );
  }
}