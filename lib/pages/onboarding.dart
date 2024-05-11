/*
  [Title]
  OnBoardingPage

  [Description]
  Displays instructions for the user when launching the program for the first time.
*/

part of '../main.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  int currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  // Sets the state on whether onboarding has already been visited.
  void saveIsOnboardingVisited(bool state) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboardingVisited', state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                    controller: _pageController,
                    itemCount: AppLocalizations.of(context)!
                        .onBoardingImages
                        .split(':')
                        .length,
                    onPageChanged: (int index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return OnBoardingPageContent(
                        image: AppLocalizations.of(context)!
                            .onBoardingImages
                            .split(':')[index],
                        title: AppLocalizations.of(context)!
                            .onBoardingTitles
                            .split(':')[index],
                        description: AppLocalizations.of(context)!
                            .onBoardingDescriptions
                            .split(':')[index],
                      );
                    }),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  AppLocalizations.of(context)!
                      .onBoardingImages
                      .split(':')
                      .length,
                  (index) => buildDot(index, context),
                ),
              ),
              Container(
                height: 40,
                margin: const EdgeInsets.all(40),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (currentIndex ==
                        AppLocalizations.of(context)!
                                .onBoardingImages
                                .split(':')
                                .length -
                            1) {
                      // saveIsOnboardingVisited(true);
                      saveIsOnboardingVisited(false);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false);
                    }
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.primary),
                    foregroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.onPrimary),
                  ),
                  child: Text(
                    currentIndex ==
                            AppLocalizations.of(context)!
                                    .onBoardingImages
                                    .split(':')
                                    .length -
                                1
                        ? AppLocalizations.of(context)!.onBoardingContinue
                        : AppLocalizations.of(context)!.onBoardingNext,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontVariations: [
                        FontVariation('wght', 700),
                      ],
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Container buildDot(int index, BuildContext context) {
    return Container(
      height: 5,
      width: currentIndex == index ? 12 : 5,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// Defines each swipable frame in OnBoardingPage.
class OnBoardingPageContent extends StatelessWidget {
  const OnBoardingPageContent(
      {super.key,
      required this.image,
      required this.title,
      required this.description});

  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Stack(alignment: const Alignment(0, 1), children: <Widget>[
          Image.asset(
            image,
            height: 250,
          ),
        ]),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontVariations: [
                FontVariation('wght', 700),
              ],
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          title: Text(
            description,
            style: const TextStyle(
              fontFamily: 'Source Sans 3',
              fontVariations: [
                FontVariation('wght', 400),
              ],
              fontSize: 14,
              height: 1.2,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
