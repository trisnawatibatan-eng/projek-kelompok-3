import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/janji_temu_screen.dart';
import '../screens/laporan_screen.dart';
import '../screens/profile_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00BBA7),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex)
          return; // Jangan navigasi jika sudah di halaman yang sama

        Widget targetScreen;
        switch (index) {
          case 0:
            targetScreen = const DashboardScreen();
            break;
          case 1:
            targetScreen = const BookingScreen();
            break;
          case 2:
            targetScreen = const JanjiTemuScreen();
            break;
          case 3:
            targetScreen = const LaporanScreen();
            break;
          case 4:
            targetScreen = const ProfileScreen();
            break;
          default:
            return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Beranda",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          activeIcon: Icon(Icons.favorite),
          label: "Pemesanan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          activeIcon: Icon(Icons.calendar_today),
          label: "Janji Temu",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_outlined),
          activeIcon: Icon(Icons.assignment),
          label: "Laporan",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Profil",
        ),
      ],
    );
  }
}
