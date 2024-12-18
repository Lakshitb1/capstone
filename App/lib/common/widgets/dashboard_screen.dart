import 'package:cap_1/features/home/home_screen.dart';
import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _page = 0;
  double bottomBarWidth = 42;
  double bottonBarBorderWidth = 5;

  List<Widget> pages = [
    const HomeScreen(),
    const Center(
      child: Text('Settings'),
    ),
  ];

  void updatePage(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_page],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _page,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.white,
        iconSize: 28,
        onTap: updatePage,
        items: [
          BottomNavigationBarItem(
              icon: Container(
                width: bottomBarWidth,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: _page == 0 ? bottonBarBorderWidth : 0,
                      color: _page == 0 ? Colors.blue : Colors.transparent,
                    ),
                  ),
                ),
                child: const Icon(Icons.home_outlined),
              ),
              label: ''),
          BottomNavigationBarItem(
              icon: Container(
                width: bottomBarWidth,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: _page == 1 ? bottonBarBorderWidth : 0,
                      color: _page == 1 ? Colors.blue : Colors.transparent,
                    ),
                  ),
                ),
                child: const Icon(Icons.settings),
              ),
              label: ''),
        ],
      ),
    );
  }
}
