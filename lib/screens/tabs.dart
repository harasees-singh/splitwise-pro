import 'package:flutter/material.dart';
import 'package:splitwise_pro/screens/home.dart';
import 'package:splitwise_pro/screens/logs.dart';
import 'package:splitwise_pro/screens/overview.dart';
import 'package:splitwise_pro/screens/settle_up.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key, this.index, required this.groupId});

  final int? index;
  final String groupId;
  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _currentIndex = 0;

  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      _currentIndex = widget.index!;
    }
    _tabs = [
      HomeScreen(groupId: widget.groupId),
      SettleUpScreen(
        setIndex: setIndex,
        groupId: widget.groupId,
      ),
      OverviewScreen(
        groupId: widget.groupId,
      ),
      LogsScreen(
        groupId: widget.groupId,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setIndex(index);
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
