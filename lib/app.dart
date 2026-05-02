
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';


import 'screens/splash/splash_screen.dart';
import 'screens/auth/auth_screens.dart';
import 'screens/profile_setup/profile_setup_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/habits/habits_screen.dart';
import 'screens/medications/medications_screen.dart';
import 'screens/chatbot/chatbot_screen.dart';
import 'screens/lifestyle/lifestyle_checkups_screens.dart';
import 'screens/risk_insights/risk_profile_screens.dart';

class GreenBasketApp extends StatelessWidget {
  const GreenBasketApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityProvider>();

    return MaterialApp(
      title: 'GreenBasket+',
      debugShowCheckedModeBanner: false,
      theme: accessibility.highContrast
          ? AppTheme.accessibleTheme
          : AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash':         (_) => const SplashScreen(),
        '/login':          (_) => const LoginScreen(),
        '/signup':         (_) => const SignupScreen(),
        '/profile-setup':  (_) => const ProfileSetupScreen(),
        '/main':           (_) => const MainShell(),
        '/risk-insights':  (_) => const RiskInsightsScreen(),
        '/lifestyle':      (_) => const LifestyleScreen(),
        '/checkups':       (_) => const CheckupsScreen(),
      },
    );
  }
}


class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // The 5 main tab screens
  final List<Widget> _screens = const [
    DashboardScreen(),
    HabitsScreen(),
    MedicationsScreen(),
    ChatbotScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityProvider>();

    return Scaffold(
      body: IndexedStack(
        // IndexedStack keeps state alive when switching tabs
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _GBBottomNav(
        currentIndex: _currentIndex,
        isAccessible: accessibility.accessibilityMode,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}


class _GBBottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isAccessible;
  final ValueChanged<int> onTap;

  const _GBBottomNav({
    required this.currentIndex,
    required this.isAccessible,
    required this.onTap,
  });

  static const List<_NavItem> _items = [
    _NavItem(icon: Icons.home_outlined,       activeIcon: Icons.home_rounded,            label: 'Home'),
    _NavItem(icon: Icons.checklist_outlined,  activeIcon: Icons.checklist_rounded,       label: 'Habits'),
    _NavItem(icon: Icons.medication_outlined, activeIcon: Icons.medication_rounded,      label: 'Medicines'),
    _NavItem(icon: Icons.smart_toy_outlined,  activeIcon: Icons.smart_toy_rounded,       label: 'GreenBot'),
    _NavItem(icon: Icons.person_outline,      activeIcon: Icons.person_rounded,          label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: const Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: isAccessible ? 80 : 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isActive = currentIndex == i;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Active indicator pill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.symmetric(
                            horizontal: isActive ? 14 : 0,
                            vertical: isActive ? 6 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primarySurface : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive ? AppColors.primary : AppColors.textLight,
                            size: isAccessible ? 28 : 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: isAccessible ? 13 : 11,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? AppColors.primary : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}