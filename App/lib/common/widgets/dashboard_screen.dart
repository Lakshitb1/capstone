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
      child: Text('Notifications'),
    ),
    const Center(
      child: Text('Search'),
    ),
    const Center(
      child: Text('Settings'),
    ),
    const Center(
      child: Text('Profile'),
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
                child: const Icon(Icons.notification_add_rounded),
              ),
              label: ''),
          BottomNavigationBarItem(
              icon: Container(
                width: bottomBarWidth,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: _page == 2 ? bottonBarBorderWidth : 0,
                      color: _page == 2 ? Colors.blue : Colors.transparent,
                    ),
                  ),
                ),
                child: const Icon(Icons.search_outlined),
              ),
              label: ''),
          BottomNavigationBarItem(
              icon: Container(
                width: bottomBarWidth,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      width: _page == 3 ? bottonBarBorderWidth : 0,
                      color: _page == 3 ? Colors.blue : Colors.transparent,
                    ),
                  ),
                ),
                child: const Icon(Icons.settings),
              ),
              label: ''),
          BottomNavigationBarItem(
            icon: Container(
              width: bottomBarWidth,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: _page == 4 ? bottonBarBorderWidth : 0,
                    color: _page == 4 ? Colors.blue : Colors.transparent,
                  ),
                ),
              ),
              child: const Icon(Icons.circle_rounded),
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
