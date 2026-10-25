import 'package:flutter/material.dart';
import '../widgets/animated_background.dart';
import '../widgets/app_navbar.dart';
import 'home_content.dart';
import 'services_screen.dart';
import 'works_screen.dart';
import 'gallery_screen.dart';
import 'contact_screen.dart';

class HomeShell extends StatefulWidget {
  final int? worksSerial;
  final int? initialTab;

  const HomeShell({
    super.key,
    this.worksSerial,
    this.initialTab,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    if (widget.worksSerial != null) {
      _currentIndex = 2; // works
    } else if (widget.initialTab != null) {
      _currentIndex = widget.initialTab!;
    } else {
      _currentIndex = 0;
    }
  }

  void _goToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeContent(onNavigateToTab: _goToTab), // ✅ نمرر callback
      const ServicesScreen(),
      WorksScreen(scrollToSerial: widget.worksSerial),
      const GalleryScreen(),
      const ContactScreen(),
    ];

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppNavBar(
          currentIndex: _currentIndex,
          onTabChanged: _goToTab,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
      ),
    );
  }
}
