part of main;

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  int currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

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
                  itemCount: onBoardingModels.length,
                  onPageChanged: (int index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) => OnBoardingContent(
                    image: onBoardingModels[index].image,
                    title: onBoardingModels[index].title,
                    description: onBoardingModels[index].description,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onBoardingModels.length,
                  (index) => buildDot(index, context),
                ),
              ),
              Container(
                height: 40,
                margin: const EdgeInsets.all(40),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.primaryContainer),
                    foregroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.primary),
                  ),
                  child: Text(
                    currentIndex == onBoardingModels.length - 1
                        ? "Continue"
                        : "Next",
                    style: const TextStyle(
                      fontFamily: 'Bahnschrift',
                      fontVariations: [
                        FontVariation('wght', 300),
                        FontVariation('wdth', 100),
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
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class OnBoardingContent extends StatelessWidget {
  const OnBoardingContent(
      {Key? key,
      required this.image,
      required this.title,
      required this.description})
      : super(key: key);

  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Stack(alignment: const Alignment(0, 1), children: <Widget>[
          Image.asset(
            image,
            height: 200,
          ),
        ]),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Bahnschrift',
              fontVariations: [
                FontVariation('wght', 700),
                FontVariation('wdth', 100),
              ],
              fontSize: 40,
            ),
          ),
        ),
        ListTile(
          title: Text(
            description,
            style: const TextStyle(
              fontFamily: 'Bahnschrift',
              fontVariations: [
                FontVariation('wght', 300),
                FontVariation('wdth', 100),
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
