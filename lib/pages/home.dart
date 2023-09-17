part of main;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false);
      }
    } catch (e) {
      bool darkMode = Theme.of(context).brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "There was an error logging out your account. Please try again later.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
                fontFamily: 'Bahnschrift',
                fontVariations: const [
                  FontVariation('wght', 350),
                  FontVariation('wdth', 100),
                ],
              )),
          backgroundColor: MaterialColors.getSurfaceContainer(darkMode),
        ),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: MaterialColors.getSurface(darkMode),
      body: Column(
        children: [
          Text(FirebaseAuth.instance.currentUser!.uid),
          const SizedBox(height: 20),
          ElevatedButton(
            child: const Text("Log Out"),
            onPressed: () {
              logoutUser();
            },
          )
        ],
      ),
    );
  }
}
