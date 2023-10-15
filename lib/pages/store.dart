part of main;

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Map places = {};

  // Fetches a list of owned places from the user.
  void getPlaces() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    db.collection("users").doc(uid).get().then((document) {
      if (document.exists) {
        List placeIDs = document.data()!['places'];
        for (String placeID in placeIDs) {
          db.collection("places").doc(placeID).get().then((document) {
            if (mounted) {
              setState(() {
                places[placeID] = document.data()!;
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    if (places.isEmpty) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: Image.network(
                    "https://em-content.zobj.net/source/microsoft-teams/363/star-struck_1f929.png"),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text.rich(
                  const TextSpan(children: [
                    TextSpan(
                        text: 'You have no owned stores yet. ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: 'Setup your business and start selling!'),
                  ]),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Bahnschrift',
                      fontVariations: const [
                        FontVariation('wght', 400),
                        FontVariation('wdth', 100),
                      ],
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 15,
                      height: 1.1,
                      letterSpacing: -0.3),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const StoreCreatePage()),
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.primary),
                          foregroundColor: MaterialStatePropertyAll(
                              Theme.of(context).colorScheme.onPrimary),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Start selling",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontFamily: 'Bahnschrift',
                              fontVariations: const [
                                FontVariation('wght', 600),
                                FontVariation('wdth', 100),
                              ],
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return const Scaffold(body: Text("Hello!"));
  }
}
