part of main;

class OrderSuccessPage extends StatefulWidget {
  const OrderSuccessPage({super.key});

  @override
  State<OrderSuccessPage> createState() => _OrderSuccessPageState();
}

class _OrderSuccessPageState extends State<OrderSuccessPage> {
  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
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
                  "https://em-content.zobj.net/source/microsoft-teams/363/partying-face_1f973.png"),
            ),
            const SizedBox(height: 20),
            Text(
              "Order has been placed",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Bahnschrift',
                  fontVariations: const [
                    FontVariation('wght', 700),
                    FontVariation('wdth', 100),
                  ],
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                  letterSpacing: -0.5),
            ),
            Text(
              "You can monitor the status of your\norder within your profile",
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
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        //TODO: Add functionality to the button to go to orders.
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
                          "View my orders",
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
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => HomePage()),
                            (Route<dynamic> route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        foregroundColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        side: BorderSide(
                            width: 2.0,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "Go back",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
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
}
