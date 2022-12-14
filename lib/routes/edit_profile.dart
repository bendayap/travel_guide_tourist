import 'package:travel_guide_tourist/imports.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({
    Key? key,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  var touristData = {};
  String photoUrl = '';

  final formKey = GlobalKey<FormState>();
  final fullnameController = TextEditingController();
  final usernameController = TextEditingController();
  final icNumberController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    fullnameController.dispose();
    usernameController.dispose();
    icNumberController.dispose();
    phoneNumberController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    try {
      // setState(() {
      //   isLoading = true;
      // });
      var touristSnap = await FirebaseFirestore.instance
          .collection('tourists')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      touristData = touristSnap.data()!;
      fullnameController.text = touristData['fullname'];
      usernameController.text = touristData['username'];
      icNumberController.text = touristData['icNumber'];
      // .replaceAll(RegExp(r'[^0-9]'), '');
      phoneNumberController.text = touristData['phoneNumber'];
      // .replaceAll(RegExp(r'[^0-9]'), '');
      descriptionController.text = touristData['description'];

      photoUrl = touristData['photoUrl'];

      setState(() {});
    } catch (e) {
      Utils.showSnackBar(e.toString());
    }
  }

  ///TODO: validation and conditions
  // bool phoneNumberFormatCorrected = false;
  // bool icNumberFormatCorrected = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            currentFocus.focusedChild?.unfocus();
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.mainBackground,
          appBar: AppBar(
            title: const Text('Edit Profile'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, true),
            ),
            backgroundColor: AppTheme.mainAppBar,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: Image.network(
                      photoUrl,
                      height: 100,
                      width: 100,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                        title: const Text('Change Picture.'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Cancel');
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              pickImageFromGallery();
                              Navigator.pop(context);
                            },
                            child: const Text('Gallery'),
                          ),
                          TextButton(
                            onPressed: () {
                              pickImageFromCamera();
                              Navigator.pop(context);
                            },
                            child: const Text('Camera'),
                          ),
                        ],
                      ),
                      );
                    },
                    child: const Text('Upload Image'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    ///Fullname Field
                    controller: fullnameController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Fullname',
                      border: OutlineInputBorder(),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && value.isEmpty
                        ? 'Enter your name'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    ///Username Field
                    controller: usernameController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && value.isEmpty
                        ? 'Enter a username'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    ///icNo Field
                    controller: icNumberController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'IC No',
                      border: OutlineInputBorder(),
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && value.length != 12
                        ? 'Enter IC Number with 12-digits only'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    ///Phone No Field
                    ///TODO: format numbers
                    controller: phoneNumberController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      // PhoneNumberFormatter(),
                      // MaskedInputFormatter('+(60) ##-#######'),
                    ],
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Phone No',
                      border: OutlineInputBorder(),
                      // hintText: phone,
                    ),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) => value != null && (value.length < 11 || value.length > 12)
                        // && (value[0] != '0' && value[1] != '1')
                        ? 'Enter a valid Phone Number'
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    ///Description Field
                    controller: descriptionController,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'About Me',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                    ),
                    icon: const Icon(Icons.edit, size: 24),
                    label: const Text(
                      'Confirm to edit',
                      style: TextStyle(fontSize: 24),
                    ),
                    onPressed: () {
                      editProfile();
                      Navigator.pop(context, true);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );

  Future editProfile() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    String fullname = fullnameController.text.trim();
    String username = usernameController.text.trim();
    String icNumber = icNumberController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();
    String description = descriptionController.text.trim();

    final isValid = formKey.currentState!.validate();
    if (!isValid) return;

    try {
      ///Edit tourist document
      Tourist tourist = Tourist(
        uid: touristData['uid'],
        username: username,
        fullname: fullname,
        phoneNumber: phoneNumber,
        email: touristData['email'],
        icNumber: icNumber,
        photoUrl: photoUrl,
        description: description,
        rating: touristData['rating'],
        icVerified: touristData['icVerified'],
      );

      await firestore
          .collection("tourists")
          .doc(touristData['uid'])
          .set(tourist.toJson());
    } on FirebaseAuthException catch (e) {
      Utils.showSnackBar(e.message);
    }

    Utils.showSnackBarSuccess('Profile Edited');
  }

  pickImageFromGallery() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    String url = await uploadImageToStorage('ProfilePics', im, false);
    setState(() {
      photoUrl = url;
    });
  }

  pickImageFromCamera() async {
    Uint8List im = await pickImage(ImageSource.camera);
    // set state because we need to display the image we selected on the circle avatar
    String url = await uploadImageToStorage('ProfilePics', im, false);
    setState(() {
      photoUrl = url;
    });
  }

  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      return await file.readAsBytes();
    }
  }

  Future<String> uploadImageToStorage(
      String childName, Uint8List file, bool isPost) async {
    // creating location to our firebase storage
    final FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage
        .ref()
        .child(childName)
        .child(FirebaseAuth.instance.currentUser!.uid);
    if (isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    // putting in uint8list format -> Upload task like a future but not future
    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final int newTextLength = newValue.text.length;
    int selectionIndex = newValue.selection.end;
    int usedSubstringIndex = 0;
    final StringBuffer newText = StringBuffer();
    if (newTextLength >= 1) {
      newText.write('+');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    if (newTextLength >= 3) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 2)} ');
      if (newValue.selection.end >= 2) selectionIndex += 1;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

// class PhoneNumberFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue previousValue,
//       TextEditingValue nextValue,
//       ) {
//     var inputText = nextValue.text;
//
//     if (nextValue.selection.baseOffset == 0) {
//       return nextValue;
//     }
//
//     var countryNumberCode = '+(60) ';
//     var bufferString = StringBuffer();
//     for (int i = 0; i < inputText.length; i++) {
//       // if (inputText.length == 1) {
//       //   bufferString.write(countryNumberCode);
//       // }
//       bufferString.write(inputText[i]);
//       // var nonZeroIndexValue = i + 1;
//       // if (nonZeroIndexValue % 2 == 0 && nonZeroIndexValue != inputText.length) {
//       //   bufferString.write('/');
//       // }
//     }
//
//     var string = bufferString.toString();
//     return nextValue.copyWith(
//       text: string,
//       selection: TextSelection.collapsed(
//         offset: string.length,
//       ),
//     );
//   }
// }
