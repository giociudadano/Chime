class OnBoardingModel {
  final String image, title, description;

  OnBoardingModel(
      {required this.image, required this.title, required this.description});
}

final List<OnBoardingModel> onBoardingModels = [
  OnBoardingModel(
      image: "lib/assets/images/logo.png",
      title: "A Title",
      description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
  OnBoardingModel(
      image: "lib/assets/images/logo.png",
      title: "B Title",
      description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
  OnBoardingModel(
      image: "lib/assets/images/logo.png",
      title: "C Title",
      description:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
];
