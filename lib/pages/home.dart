import 'package:flutter/material.dart';
import 'package:flexly/widgets/app_bottom_navigation_bar.dart';
import 'package:flexly/pages/home_content.dart';
import 'package:flexly/pages/training_page.dart';
import 'package:flexly/pages/analysis_page.dart';
import 'package:flexly/pages/statistics_page.dart';
import 'package:flexly/pages/profile_page.dart';
import 'package:flexly/pages/lock_screen.dart';
import 'package:flexly/theme/app_colors.dart';
import 'package:flexly/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late int _currentIndex;
  bool _lockShowing = false;
  static const _unlockTokenKey = 'lock_token_expiry_ms';
  static const _tokenTtl = Duration(minutes: 20);
  final _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAppLock());
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAppLock();
    }
  }

  Future<void> _checkAppLock() async {
    if (_lockShowing) return;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final tokenMs = prefs.getInt(_unlockTokenKey);
    if (tokenMs != null) {
      final tokenExpiry = DateTime.fromMillisecondsSinceEpoch(tokenMs);
      if (now.isBefore(tokenExpiry)) {
        return;
      }
    }

    final requirePasscode = prefs.getBool('privacy_passcode') ?? false;
    final biometricOn = prefs.getBool('privacy_biometric') ?? false;

    if (!requirePasscode && !biometricOn) return;

    _lockShowing = true;

    final unlocked = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => LockScreen(
          biometricsEnabled: biometricOn,
          localAuth: _localAuth,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    _lockShowing = false;
    if (!mounted) return;

    if (unlocked == true) {
      final expiry = now.add(_tokenTtl);
      await prefs.setInt(_unlockTokenKey, expiry.millisecondsSinceEpoch);
      return;
    }

    if (requirePasscode || biometricOn) {
      // If user cancelled or failed, try again when app is next resumed
      Future.microtask(_checkAppLock);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeContent(onTabChange: _onTabChange),
      const TrainingPage(),
      const AnalysisPage(),
      // Reload StatisticsPage every time it's opened to refresh data
      _currentIndex == 3 ? const StatisticsPage() : const SizedBox(),
      ProfilePage(onNavigateToAnalysis: () => _onTabChange(2)),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChange,
      ),
    );
  }
}
