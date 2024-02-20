part of '../main.dart';

// ignore: must_be_immutable
class StoreEditPage extends StatefulWidget {
  StoreEditPage(this.placeID, this.place, {super.key, this.editStoreCallback});

  String placeID;
  Map place;

  final Function(String placeID, String? placeImageURL, Map data)?
      editStoreCallback;

  @override
  State<StoreEditPage> createState() => _StoreEditPageState();
}

class _StoreEditPageState extends State<StoreEditPage> {
  // Variables for controllers.
  final GlobalKey<FormState> formEditStoreKey = GlobalKey<FormState>();
  final inputEditStoreName = TextEditingController();
  final inputEditStoreDesc = TextEditingController();
  final inputEditStoreDeliveryFee = TextEditingController();
  final inputEditStorePhoneNumber = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? newImage;
  bool toDeletePlaceImage = false;

  void editStore(String placeID, Map data) async {
    try {
      // 1. Updates store data
      FirebaseFirestore db = FirebaseFirestore.instance;
      db.collection("places").doc(placeID).update(Map.from(data));
      Navigator.pop(context);

      // 2. Updates profile picture
      Reference ref =
          FirebaseStorage.instance.ref('places/${widget.placeID}.jpg');
      if (toDeletePlaceImage) {
        await ref.delete();
      }

      if (newImage != null) {
        try {
          await ref.putFile(
              newImage!,
              SettableMetadata(
                contentType: "image/jpeg",
              ));
          String placeImageURL = await ref.getDownloadURL();
          widget.editStoreCallback!(placeID, placeImageURL, data);
        } catch (e) {
          // ...
        }
      } else {
        widget.editStoreCallback!(
            placeID, toDeletePlaceImage ? '' : null, data);
      }
    } catch (e) {
      //
    }
  }

  // Checks if the name field is empty and returns an error if so.
  String? _verifyNameField(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your name";
    }
    return null;
  }

  // Checks if the delivery fee field is a non-integer and returns an error if so.
  String? _verifyDeliveryFeeField(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      int.parse(value);
      return null;
    } on FormatException {
      return 'Please enter a whole number';
    }
  }

  // Checks if the delivery fee field is a non-integer and returns an error if so.
  String? _verifyContactNumberField(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    try {
      int.parse(value);
      return null;
    } on FormatException {
      return 'Please enter a whole number';
    }
  }

  Future setPlaceImage(
    ImageSource source, {
    required BuildContext context,
    bool isMultiImage = false,
    bool isMedia = false,
  }) async {
    if (kIsWeb) {
      bool darkMode = Theme.of(context).brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Sorry, you cannot edit place images on web devices at this time.",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 13.5,
                fontFamily: 'Bahnschrift',
                fontVariations: const [
                  FontVariation('wght', 350),
                  FontVariation('wdth', 100),
                ],
                letterSpacing: -0.5,
              )),
          backgroundColor: MaterialColors.getSurfaceContainer(darkMode),
        ),
      );
      return;
    } else {
      try {
        final List<XFile> pickedFileList = <XFile>[];
        final XFile? media = await _picker.pickMedia();
        if (media != null) {
          pickedFileList.add(media);
          setState(() {
            toDeletePlaceImage = false;
            newImage = File(media.path);
          });
        }
      } catch (e) {
        //
      }
    }
  }

  void deletePlaceImage() {
    setState(() {
      toDeletePlaceImage = true;
      newImage = null;
    });
  }

  @override
  void initState() {
    inputEditStoreName.text = widget.place['placeName'];
    inputEditStoreDesc.text = widget.place['placeTagline'] ?? '';
    // If there is no entry in the database for the delivery price, set delivery
    // price to zero.
    inputEditStoreDeliveryFee.text = widget.place['deliveryPrice'] != null
        ? widget.place['deliveryPrice'].toString()
        : '0';
    inputEditStorePhoneNumber.text = widget.place['phoneNumber'] == null
        ? ''
        : widget.place['phoneNumber'].substring(4);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: MaterialColors.getSurfaceContainerLowest(darkMode),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 50),
            child: Text(
              "Edit Store",
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontFamily: 'Plus Jakarta Sans',
                  fontVariations: const [
                    FontVariation('wght', 700),
                  ],
                  fontSize: 20,
                  letterSpacing: -0.3),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: formEditStoreKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Card(
                        color: MaterialColors.getSurfaceContainerLow(darkMode),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 0,
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: FittedBox(
                            clipBehavior: Clip.hardEdge,
                            fit: BoxFit.cover,
                            child: newImage != null
                                ? Image.file(newImage!)
                                : CachedNetworkImage(
                                    imageUrl: toDeletePlaceImage
                                        ? ''
                                        : widget.place['placeImageURL'] ?? '',
                                    placeholder: (context, url) =>
                                        const Padding(
                                      padding: EdgeInsets.all(40.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Padding(
                                      padding: const EdgeInsets.all(40.0),
                                      child: Icon(Icons.storefront_outlined,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outlineVariant),
                                    ),
                                    fadeInCurve: Curves.easeIn,
                                    fadeOutCurve: Curves.easeOut,
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!toDeletePlaceImage)
                          ElevatedButton(
                            onPressed: () {
                              deletePlaceImage();
                            },
                            style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    ChimeColors.getRed200()),
                                shape: MaterialStatePropertyAll(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide.none,
                                ))),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  color: ChimeColors.getRed800(),
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontVariations: const [
                                    FontVariation('wght', 700),
                                  ],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            setPlaceImage(ImageSource.gallery,
                                context: context);
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  MaterialColors.getSurfaceContainerLow(
                                      darkMode)),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide.none,
                              ))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Upload",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Plus Jakarta Sans',
                                fontVariations: const [
                                  FontVariation('wght', 700),
                                ],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Required items are marked with an asterisk *",
                      style: TextStyle(
                          color: ChimeColors.getRed800(),
                          fontFamily: 'Source Sans 3',
                          fontVariations: [
                            const FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(text: "Store Name", children: [
                        TextSpan(
                            text: "*",
                            style: TextStyle(color: ChimeColors.getRed800()))
                      ]),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: [
                            const FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                    ),
                    TextFormField(
                      controller: inputEditStoreName,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        hintText: "Name",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        isDense: true,
                      ),
                      style: const TextStyle(
                          letterSpacing: -0.3,
                          fontFamily: 'Source Sans 3',
                          fontVariations: [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14),
                      validator: (String? value) {
                        return _verifyNameField(value);
                      },
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Description",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: [
                            const FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                    ),
                    TextFormField(
                      controller: inputEditStoreDesc,
                      maxLength: 150,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        hintText: "Description",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                      minLines: 3,
                      maxLines: 3,
                      validator: (String? value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Delivery Fee",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: inputEditStoreDeliveryFee,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 8, 0, 0),
                          child: Text(
                            "₱",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Source Sans 3',
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 16,
                                letterSpacing: -0.3),
                          ),
                        ),
                        hintText: "0",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                      minLines: 1,
                      maxLines: 1,
                      validator: (String? value) {
                        return _verifyDeliveryFeeField(value);
                      },
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Contact Number",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontFamily: 'Source Sans 3',
                          fontVariations: const [
                            FontVariation('wght', 400),
                          ],
                          fontSize: 14,
                          letterSpacing: -0.3),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: inputEditStorePhoneNumber,
                      maxLength: 9,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        hintText: "123 456 789",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 10, 8, 0),
                          child: Text(
                            "+639",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Source Sans 3',
                                fontVariations: const [
                                  FontVariation('wght', 400),
                                ],
                                fontSize: 14,
                                letterSpacing: -0.3),
                          ),
                        ),
                        filled: true,
                        fillColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        isDense: true,
                      ),
                      style: const TextStyle(
                        fontFamily: 'Source Sans 3',
                        fontVariations: [
                          FontVariation('wght', 400),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3,
                      ),
                      minLines: 1,
                      maxLines: 1,
                      validator: (String? value) {
                        return _verifyContactNumberField(value);
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          elevation: const MaterialStatePropertyAll(0),
                          backgroundColor: MaterialStatePropertyAll(
                              MaterialColors.getSurfaceContainerLowest(
                                  darkMode)),
                          shape:
                              MaterialStatePropertyAll(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: ChimeColors.getGreen300(),
                            ),
                          )),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "Cancel",
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
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formEditStoreKey.currentState!.validate()) {
                            Map data = {
                              "placeName": inputEditStoreName.text,
                              "placeTagline": inputEditStoreDesc.text,
                              "deliveryPrice": inputEditStoreDeliveryFee
                                      .text.isNotEmpty
                                  ? int.parse(inputEditStoreDeliveryFee.text)
                                  : 0,
                              "phoneNumber": inputEditStorePhoneNumber != ""
                                  ? "+639${inputEditStorePhoneNumber.text}"
                                  : null,
                            };
                            editStore(widget.placeID, data);
                          }
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                ChimeColors.getGreen200()),
                            shape:
                                MaterialStatePropertyAll(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide.none,
                            ))),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: ChimeColors.getGreen800(),
                              fontFamily: 'Plus Jakarta Sans',
                              fontVariations: const [
                                FontVariation('wght', 700),
                              ],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
