import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  const BottomNavBar({required this.selectedIndex, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.purple,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        color: Colors.grey,
      ),
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index != selectedIndex) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/messages');
              break;
            case 2:
              Navigator.pushNamed(context, '/editor');
              break;
            case 3:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 24),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message, size: 24),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit, size: 24),
          label: 'Editor',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, size: 24),
          label: 'Setting',
        ),
      ],
    );
  }
}
