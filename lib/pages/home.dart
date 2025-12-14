import 'package:flutter/material.dart';
import 'package:flexly/widgets/app_bottom_navigation_bar.dart';
import 'package:flexly/pages/home_content.dart';
import 'package:flexly/pages/training_page.dart';
import 'package:flexly/pages/analysis_page.dart';
import 'package:flexly/pages/statistics_page.dart';
import 'package:flexly/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeContent(onTabChange: _onTabChange),
      const TrainingPage(),
      const AnalysisPage(),
      const StatisticsPage(),
      const ProfilePage(),
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
