import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  // ignore: library_private_types_in_public_api
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    getSharedPreferences();
  }

  void getSharedPreferences() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    String? theme = sharedPreferences.getString('theme');
    if (theme == 'light') {
      changeTheme(ThemeMode.light);
    } else if (theme == 'dark') {
      changeTheme(ThemeMode.dark);
    }
  }

  ThemeMode _themeMode = ThemeMode.system;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Special Problem',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: const MyHomePage(title: 'Special Problem'),
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void saveCurrentTheme(String currentTheme) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', currentTheme);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Choose your theme:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                      MyApp.of(context).changeTheme(ThemeMode.light);
                      saveCurrentTheme('light');
                    },
                    child: const Text('Light')),
                ElevatedButton(
                    onPressed: () {
                      MyApp.of(context).changeTheme(ThemeMode.dark);
                      saveCurrentTheme('dark');
                    },
                    child: const Text('Dark')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
