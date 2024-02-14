part of '../main.dart';

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
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: Placeholder(),
            ),
            const SizedBox(height: 20),
            Text(
              "Meowsome!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontVariations: const [
                    FontVariation('wght', 700),
                  ],
                  color: ChimeColors.getGreen800(),
                  fontSize: 20,
                  letterSpacing: -0.3),
            ),
            Text(
              "Your order has been placed. You can monitor its status under the Orders tab.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Source Sans 3',
                  fontVariations: const [
                    FontVariation('wght', 400),
                  ],
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 14,
                  letterSpacing: -0.3),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => HomePage()),
                          (Route<dynamic> route) => false);
                    },
                    style: ButtonStyle(
                      elevation: const MaterialStatePropertyAll(0),
                      backgroundColor: MaterialStatePropertyAll(
                          MaterialColors.getSurfaceContainerLowest(darkMode)),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: ChimeColors.getGreen300(),
                        ),
                      )),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Home",
                        style: TextStyle(
                          color: ChimeColors.getGreen800(),
                          fontFamily: 'Plus Jakarta Sans',
                          fontVariations: const [
                            FontVariation('wght', 700),
                          ],
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
