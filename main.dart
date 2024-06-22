import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:works/m.dart';
import 'package:works/q.dart';
import 'package:works/up.dart';
import 'package:works/p.dart';
import 'package:works/s.dart';
void main() {
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muslim Prayer Time Scheduler',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Color.fromARGB(255, 11, 12, 11)),
        scaffoldBackgroundColor: const Color(0xFF728359),
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      swatch[(strength * 1000).round()] = Color.fromRGBO(r, g, b, strength);
    });
    return MaterialColor(color.value, swatch);
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    PrayerTimesScreen(),
    QuranTrackerScreen(),
    MosqueLocatorScreen(),
    UserProfileScreen(),
    SettingsScreen(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Prayer Times',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Quran Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Mosque Locator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 27, 36, 13),
        onTap: _onItemTapped,
      ),
    );
  }
}
