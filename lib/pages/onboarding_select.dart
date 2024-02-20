import 'package:cmsc198/models/material_colors_model.dart';
import 'package:flutter/material.dart';

class SelectCard {
  final IconData cardIcon;
  final String cardTitle;
  final String cardSubtitle;
  SelectCard({this.cardIcon, this.cardTitle, this.cardSubtitle});
}

List<SelectCard> cardList = [
  SelectCard(
      cardIcon: Icons.local_mall,
      cardTitle: 'Buy',
      cardSubtitle: 'I want to order food.'),
  SelectCard(
      cardIcon: Icons.sell,
      cardTitle: 'Sell',
      cardSubtitle: 'I want to sell food.'),
];

class OnboardingSelect extends StatefulWidget {
  const OnboardingSelect({super.key});

  @override
  State<OnboardingSelect> createState() => _OnboardingSelectState();
}

class _OnboardingSelectState extends State<OnboardingSelect> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: MaterialColors.getSurface(darkMode),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(children: [
            Expanded(
              child: Column(
                children: [
                  const Text(
                    "How would you mainly use Chime?",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    "Please select your choice. You can change this later in your profile.",
                    maxLines: 2,
                  ),
                  SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: 2,
                        itemBuilder: (BuildContext context, int position) {
                          return InkWell(
                              onTap: () =>
                                  setState(() => selectedIndex = position),
                              child: SizedBox(
                                width: 150,
                                child: Card(
                                  shape: (selectedIndex == position)
                                      ? const RoundedRectangleBorder(
                                          side: BorderSide(color: Colors.green))
                                      : null,
                                  elevation: 5,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Icon(cardList[position].cardIcon),
                                      Text(cardList[position].cardTitle),
                                      Text(cardList[position].cardSubtitle),
                                    ],
                                  ),
                                ),
                              ));
                        },
                      )),
                  const SizedBox(height: 80),
                  const ElevatedButton(
                      onPressed: null, child: Text('Get Started'))
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
