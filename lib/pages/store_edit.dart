part of main;

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
    inputEditStoreDeliveryFee.text = widget.place['deliveryPrice'] != null
        ? widget.place['deliveryPrice'].toString()
        : '0';
    inputEditStorePhoneNumber.text = widget.place['phoneNumber'] ?? '';
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
                  fontFamily: 'Bahnschrift',
                  fontVariations: const [
                    FontVariation('wght', 700),
                    FontVariation('wdth', 100),
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
          child: ListView(
            children: [
              Text(
                "Appearance",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 700),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 16,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 10),
              Center(
                child: Card(
                  color: MaterialColors.getSurfaceContainerLow(darkMode),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 0,
                  child: Stack(
                    children: [
                      SizedBox(
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
                                  placeholder: (context, url) => const Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) => Padding(
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
                      Positioned(
                        top: 8,
                        right: 45,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Container(
                            height: 30,
                            width: 30,
                            color: (widget.place['placeImageURL'] == null &&
                                        newImage == null) ||
                                    toDeletePlaceImage
                                ? Colors.transparent
                                : const Color.fromARGB(120, 0, 0, 0),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: (widget.place['placeImageURL'] == null &&
                                            newImage == null) ||
                                        toDeletePlaceImage
                                    ? Theme.of(context).colorScheme.outline
                                    : Colors.grey[100],
                              ),
                              onPressed: () {
                                setPlaceImage(ImageSource.gallery,
                                    context: context);
                              },
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          child: Container(
                            height: 30,
                            width: 30,
                            color: (widget.place['placeImageURL'] == null &&
                                        newImage == null) ||
                                    toDeletePlaceImage
                                ? Colors.transparent
                                : const Color.fromARGB(120, 0, 0, 0),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.close,
                                size: 22,
                                color: (widget.place['placeImageURL'] == null &&
                                            newImage == null) ||
                                        toDeletePlaceImage
                                    ? Theme.of(context).colorScheme.outline
                                    : Colors.grey[100],
                              ),
                              onPressed: () {
                                deletePlaceImage();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Basic Information",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 700),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 16,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 10),
              Text(
                'Name',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 450),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 14,
                    letterSpacing: -0.3),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 5),
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
                  hintText: "Insert your store's name",
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.outline),
                  filled: true,
                  fillColor: MaterialColors.getSurfaceContainerLowest(darkMode),
                  isDense: true,
                ),
                style: const TextStyle(
                    fontFamily: 'Bahnschrift',
                    fontVariations: [
                      FontVariation('wght', 300),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 13.5,
                    letterSpacing: -0.5),
                validator: (String? value) {
                  return _verifyNameField(value);
                },
              ),
              const SizedBox(height: 15),
              Text(
                'Description',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontFamily: 'Bahnschrift',
                    fontVariations: const [
                      FontVariation('wght', 400),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 14,
                    letterSpacing: -0.3),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: inputEditStoreDesc,
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
                  hintText: "Insert your store's description",
                  hintStyle:
                      TextStyle(color: Theme.of(context).colorScheme.outline),
                  filled: true,
                  fillColor: MaterialColors.getSurfaceContainerLowest(darkMode),
                  isDense: true,
                ),
                style: const TextStyle(
                    fontFamily: 'Bahnschrift',
                    fontVariations: [
                      FontVariation('wght', 300),
                      FontVariation('wdth', 100),
                    ],
                    fontSize: 13.5,
                    letterSpacing: -0.5),
                minLines: 3,
                maxLines: 3,
                validator: (String? value) {
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Row(children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'Delivery Fee',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 400),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3),
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(width: 20),
                Text('Contact Number',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Bahnschrift',
                        fontVariations: const [
                          FontVariation('wght', 400),
                          FontVariation('wdth', 100),
                        ],
                        fontSize: 14,
                        letterSpacing: -0.3)),
              ]),
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: inputEditStoreDeliveryFee,
                      decoration: InputDecoration(
                        prefixIcon: const Padding(
                            padding: EdgeInsets.all(12), child: Text('₱ ')),
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
                        hintText: "0",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        isDense: true,
                      ),
                      style: const TextStyle(
                          fontFamily: 'Bahnschrift',
                          fontVariations: [
                            FontVariation('wght', 300),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 13.5,
                          letterSpacing: -0.5),
                      minLines: 1,
                      maxLines: 1,
                      validator: (String? value) {
                        return _verifyDeliveryFeeField(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: inputEditStorePhoneNumber,
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
                        hintText: "0912 3456 789",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.outline),
                        filled: true,
                        fillColor:
                            MaterialColors.getSurfaceContainerLowest(darkMode),
                        isDense: true,
                      ),
                      style: const TextStyle(
                          fontFamily: 'Bahnschrift',
                          fontVariations: [
                            FontVariation('wght', 300),
                            FontVariation('wdth', 100),
                          ],
                          fontSize: 13.5,
                          letterSpacing: -0.5),
                      minLines: 1,
                      maxLines: 1,
                      validator: (String? value) {
                        return _verifyContactNumberField(value);
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formEditStoreKey.currentState!.validate()) {
                          Map data = {
                            "placeName": inputEditStoreName.text,
                            "placeTagline": inputEditStoreDesc.text,
                            "deliveryPrice":
                                inputEditStoreDeliveryFee.text.isNotEmpty
                                    ? int.parse(inputEditStoreDeliveryFee.text)
                                    : 0,
                            "phoneNumber":
                                inputEditStorePhoneNumber.text.isNotEmpty
                                    ? inputEditStorePhoneNumber.text
                                    : null,
                          };
                          editStore(widget.placeID, data);
                        }
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
                          "Submit",
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
