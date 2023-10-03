part of main;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        bottomNavigationBar: Container(
            color: MaterialColors.getSurfaceContainerLow(darkMode),
            child: menu()),
        body: const TabBarView(
          children: [
            ProductsPage(),
            PlacesPage(),
            Icon(Icons.directions_bike),
            ProfilePage(),
          ],
        ),
      ),
    );
  }

  Widget menu() {
    return TabBar(
      tabs: [
        Tab(
          height: 60,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.local_mall_outlined),
              Text(
                AppLocalizations.of(context)!.navTabShop,
                style: const TextStyle(
                    fontFamily: 'Bahnschrift',
                    fontVariations: [
                      FontVariation('wght', 500),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 13,
                    letterSpacing: -0.3),
              ),
            ],
          ),
        ),
        Tab(
          height: 60,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.storefront_outlined),
              Text(
                AppLocalizations.of(context)!.navTabPlaces,
                style: const TextStyle(
                    fontFamily: 'Bahnschrift',
                    fontVariations: [
                      FontVariation('wght', 500),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 13,
                    letterSpacing: -0.3),
              )
            ],
          ),
        ),
        Tab(
          height: 60,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.payments_outlined),
              Text(
                AppLocalizations.of(context)!.navTabStore,
                style: const TextStyle(
                    fontFamily: 'Bahnschrift',
                    fontVariations: [
                      FontVariation('wght', 500),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 13,
                    letterSpacing: -0.3),
              )
            ],
          ),
        ),
        Tab(
          height: 60,
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.account_circle_outlined),
              Text(
                AppLocalizations.of(context)!.navTabProfile,
                style: const TextStyle(
                    fontFamily: 'Bahnschrift',
                    fontVariations: [
                      FontVariation('wght', 500),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 13,
                    letterSpacing: -0.3),
              )
            ],
          ),
        ),
      ],
    );
  }
}
