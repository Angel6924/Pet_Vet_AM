import 'package:flutter/material.dart';
import 'package:reserva_pet_vet/features/reserva_vet/presentation/views/reserva.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    Center(child: Text('Home Screen')), // Define the main screen
    Center(child: Text('Pets Screen')),
    Center(child: Text('Hostel Screen')),
    ReservaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        elevation: 0,
        iconSize: 18, // Ajusta el tamaño de los iconos
        selectedFontSize: 10, // Tamaño de la fuente cuando está seleccionado
        unselectedFontSize: 9, // Tamaño de la fuente cuando no está seleccionado
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            activeIcon: const Icon(Icons.home),
            label: 'Home',
            backgroundColor: colors.primary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.store),
            activeIcon: const Icon(Icons.store),
            label: 'Store',
            backgroundColor: colors.primary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pets),
            activeIcon: const Icon(Icons.pets_outlined),
            label: 'Pets',
            backgroundColor: colors.tertiary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bed_outlined),
            activeIcon: const Icon(Icons.bed_outlined),
            label: 'Reservation',
            backgroundColor: colors.tertiary,
          ),
        ],
        selectedItemColor: const Color.fromARGB(255, 142, 50, 239),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
