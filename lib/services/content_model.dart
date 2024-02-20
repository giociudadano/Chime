class PageContent {
  final String image, title, description;

  PageContent(
      {required this.image,
      required this.title,
      required this.description});
}

final List<PageContent> contents = [
  PageContent(
    image: "lib/assets/images/Buy.png",
    title: "Buy Online",
    description:
        "Ordering online is the new fad! Have your favorite food delivered at your doorstep in just a few clicks.",
  ),
  PageContent(
    image: "lib/assets/images/Sell.png",
    title: "Sell Online",
    description: "Rather start your own food e-commerce? Create and manage your store in just one app.",
  ),
];
