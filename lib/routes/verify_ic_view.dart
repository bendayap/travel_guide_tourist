// ignore_for_file: use_build_context_synchronously

import 'package:travel_guide_tourist/imports.dart';

import '../models/verity_ic.dart';
import '../ui_view/image_full_screen.dart';
import '../ui_view/memory_image_full_screen.dart';
class VerifyIcView extends StatefulWidget {
  const VerifyIcView({super.key});

  @override
  State<VerifyIcView> createState() => _VerifyIcViewState();
}

class _VerifyIcViewState extends State<VerifyIcView> {
  bool isLoading = false;
  Uint8List? _frontImage, _backImage, _holdImage;
  String frontIcTitle = "IC Front";
  String backIcTitle = "IC Back";
  String holdIcTitle = "IC Hold";
  String status = "";
  var icData = {};
  int currentStage = 1;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var icSnap = await FirebaseFirestore.instance
          .collection('icVerifications')
          .doc("ic_${FirebaseAuth.instance.currentUser!.uid}")
          .get();

      if (icSnap.exists) {
        icData = icSnap.data()!;

        setState(() {
          status = icSnap.data()!["status"];
        });
      }
    } catch (e) {
      Utils.showSnackBar(
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  updateImage() async {
    setState(() {
      isLoading = true;
    });

    try {
      String res = await updateVerifyIC(
        FirebaseAuth.instance.currentUser!.uid,
        _frontImage, _backImage, _holdImage,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        Utils.showSnackBarSuccess(
          'Submitted!',
        );
        Navigator.of(context).pop();
      } else {
        Utils.showSnackBar( res);
        setState(() {
          isLoading = false;
        });
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      Utils.showSnackBar(
        err.toString(),
      );
    }
  }

  selectImg(String type) async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      type == frontIcTitle ?
      _frontImage = im : type == backIcTitle ?
      _backImage = im : _holdImage = im;
    });
  }

  deleteSubmittion() async {
    setState(() {
      isLoading = true;
    });

    try {
      String res = await deleteVerifyIC(
        FirebaseAuth.instance.currentUser!.uid,
      );
      if (res == "success") {
        setState(() {
          isLoading = false;
        });
        Utils.showSnackBar(
          'Deleted!',
        );
        Navigator.of(context).pop();

      } else {
        Utils.showSnackBar( res);
        setState(() {
          isLoading = false;
        });
      }
    } catch (err) {
      setState(() {
        isLoading = false;
      });
      Utils.showSnackBar(
        err.toString(),
      );
    }
  }

  Widget imageViewCard(String title, Uint8List? image) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          Text(
            "Step $currentStage: Upload your $title",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: ElevatedButton(
              onPressed: () => selectImg(title),
              child: const Text("Upload an Image"),
              // inverseColor: true,
            ),
          ),
          const SizedBox(height: 20),
          image != null ? GestureDetector(
            child: Container(
              height: 200.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white),
                image: DecorationImage(
                  image: MemoryImage(image),
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return MemoryImageFullScreen(image: image,);
              }));
            },
          ) : Container(
            height: 200.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/${
                    title == frontIcTitle ? "ic_front" :
                    title == backIcTitle ? "ic_back" : "ic_hold"
                }.jpg"),
                fit: BoxFit.fitHeight,
              ),
            ),
            child: null /* add child content here */,
          ),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              currentStage > 1 ? (
                  ElevatedButton(
                    onPressed: () => setState(() {
                      currentStage--;
                    }),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.arrow_circle_left,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10,),
                        Text(
                          "Previous",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
              ) : (
                  const SizedBox()
              ),
              currentStage < 3 ? (
                  ElevatedButton(
                    onPressed: () => {
                      if (image == null) {
                        Utils.showSnackBar(
                          'Please select an image',
                        )
                      } else {
                        setState(() {
                          currentStage++;
                        })
                      }
                    },
                    child: Row(
                      children: const [
                        Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10,),
                        Icon(
                          Icons.arrow_circle_right,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  )
              ) : (
                  const SizedBox()
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget stageAvatar(int num) {
    return CircleAvatar(
      backgroundColor: num < currentStage + 1 ?
      Theme.of(context).colorScheme.primary
          : Colors.grey,
      radius: num < currentStage + 1 ? 15 : 12,
      child: Text(
        num.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: num < currentStage + 1 ? 15 : 12,
        ),
      ),
    );
  }

  int i = 0;

  Widget showImg(String title, String imgUrl) {
    return Column(
      children: [
        Text(title),
        GestureDetector(
          child: Hero(
            tag: 'imageHero${i++}',
            child: Image(
              height: 200,
              fit: BoxFit.fitHeight,
              width: double.infinity,
              // width: double.infinity - 20,
              image: NetworkImage( imgUrl),
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return ImageFullScreen(imageUrl: imgUrl,);
            }));
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IC Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: AppTheme.mainAppBar,
        centerTitle: true,
      ),
      body: isLoading ? LoadingView() : Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.mainBackground,
        ),
        child: SingleChildScrollView(
          child: status == "" ? Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    stageAvatar(1),
                    Icon(
                      Icons.keyboard_double_arrow_right,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    stageAvatar(2),
                    Icon(
                      Icons.keyboard_double_arrow_right,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    stageAvatar(3),
                  ],
                ),
              ),

              const SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: currentStage == 1 ? (
                    imageViewCard(frontIcTitle, _frontImage)
                ) : currentStage == 2 ? (
                    imageViewCard(backIcTitle, _backImage)
                ) :  imageViewCard(holdIcTitle, _holdImage),

              ),

              const SizedBox(height: 20.0),

              currentStage == 3 ? (
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: ElevatedButton(
                      onPressed: updateImage,
                      child: const Text("Submit"),
                    ),
                  )

              ) : (
                  const SizedBox()
              ),
            ],
          ) : Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: status == "Pending" ? (
                    const Text("Your IC Verification submittion is pending for review.\n"
                        "Please wait for about 3 working days.")
                ) : (
                    const Text("Your IC has been verified")
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Divider(),
              ),

              showImg(frontIcTitle, icData["icFrontPic"]),
              const SizedBox(height: 20),
              showImg(backIcTitle, icData["icBackPic"]),
              const SizedBox(height: 20),
              showImg(holdIcTitle, icData["icHoldPic"]),
              const SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Confirm to delete?.'),
                          content: const Text(
                              'nAfter deletion, you can resubmit if necessary.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                deleteSubmittion();
                                Navigator.pop(context, 'Delete');
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );


                    },
                    child: const Text("Delete"),
                    // inverseColor: true,
                  )
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> updateVerifyIC(String uid, Uint8List? frontImg,
      Uint8List? backImg, Uint8List? holdImg) async {
    String res = "Some error occurred";
    String verifyIcId = "ic_$uid";

    try {
      if (frontImg != null && backImg != null && holdImg != null) {
        String icFrontPic = await uploadImageToStorage('TourGuideIcFrontPics', frontImg, false);
        String icBackPic = await uploadImageToStorage('TourGuideIcBackPics', backImg, false);
        String icHoldPic = await uploadImageToStorage('TourGuideIcHoldPics', holdImg, false);

        VerifyIc verifyIc = VerifyIc(
          verifyIcId: verifyIcId,
          ownerId: uid,
          icFrontPic: icFrontPic,
          icBackPic: icBackPic,
          icHoldPic: icHoldPic,
          status: "Pending",
        );

        FirebaseFirestore.instance.collection('icVerifications').doc(verifyIcId).set(verifyIc.toJson());
        res = "success";
      } else {
        res = "Please select an image";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteVerifyIC(String uid) async {
    String res = "Some error occurred";
    String verifyIcId = "ic_$uid";

    try {
      FirebaseFirestore.instance.collection('icVerifications').doc(verifyIcId).delete();
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }


  pickImage(ImageSource source) async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: source);
    if (file != null) {
      return await file.readAsBytes();
    }
    // print('No Image Selected');
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