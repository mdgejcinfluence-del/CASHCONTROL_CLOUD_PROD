import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Importation des écrans créés précédemment
import 'screens/auth/setup_pin_screen.dart';
import 'screens/dashboard/espace_employe.dart';
import 'screens/dashboard/bilan_patron.dart';
import 'screens/dashboard/employes_section.dart';
import 'screens/dashboard/services_section.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Ouverture des boîtes de stockage sécurisées
  await Hive.openBox('settings');
  await Hive.openBox('daily_sales');
  
  runApp(const CashControlCloud());
}

class CashControlCloud extends StatelessWidget {
  const CashControlCloud({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('settings');
    bool isInitialized = box.get('is_initialized', defaultValue: false);

    return MaterialApp(
      title: 'CASH CONTROL CLOUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        useMaterial3: true,
      ),
      // Si le PIN n'est pas configuré, on force l'Étape 0
      initialRoute: isInitialized ? '/home' : '/setup',
      routes: {
        '/setup': (context) => const SetupPinScreen(),
        '/home': (context) => const MainNavigation(),
        '/bilan': (context) => const BilanPatron(),
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const EspaceEmploye(),
    const ConfigGlobal(), // Regroupe Employés et Services
    const BilanPatron(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CASH CONTROL CLOUD"),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline),
            onPressed: () => Navigator.pushReplacementNamed(context, '/setup'),
          )
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.engineering), label: 'Employé'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Patron'),
        ],
      ),
    );
  }
}

// Widget simple pour regrouper les sections de config
class ConfigGlobal extends StatelessWidget {
  const ConfigGlobal({super.key});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          EmployesSection(),
          ServicesSection(),
        ],
      ),
    );
  }
}