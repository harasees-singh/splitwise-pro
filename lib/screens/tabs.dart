import 'package:flutter/material.dart';
import 'package:splitwise_pro/screens/home.dart';
import 'package:splitwise_pro/screens/logs.dart';
import 'package:splitwise_pro/screens/overview.dart';
import 'package:splitwise_pro/screens/settle_up.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key, this.index}) :super(key: key);

  final int? index;
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      _currentIndex = widget.index!;
    }
  }

  final List<Widget> _tabs = [
    const HomeScreen(),
    const SettleUpScreen(),
    const OverviewScreen(),
    const LogsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: 'Pay'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment_outlined), label: 'Overview'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_tree_outlined), label: 'Logs'),
        ],
      ),
    );
  }
}
