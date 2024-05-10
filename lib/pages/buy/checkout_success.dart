part of '../../main.dart';

class CheckoutSuccessPage extends StatefulWidget {
  const CheckoutSuccessPage({super.key});

  @override
  State<CheckoutSuccessPage> createState() => _CheckoutSuccessPageState();
}

class _CheckoutSuccessPageState extends State<CheckoutSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 240,
              width: 240,
              child: Image(image: AssetImage('lib/assets/images/Chime.png')),
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
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 24,
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
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
                          Theme.of(context).colorScheme.primary),
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide.none,
                      )),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Back to Home",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontFamily: 'Manrope',
                          fontVariations: const [
                            FontVariation('wght', 700),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3,
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
