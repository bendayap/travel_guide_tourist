import 'package:travel_guide_tourist/imports.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textController = TextEditingController();
  final digitController = TextEditingController();
  bool isLoading = false;
  int numberOfTourist = 0;
  int numberOfTourGuide = 0;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    try {
      setState(() {
        isLoading = true;
      });

      final int tourDoc = await FirebaseFirestore.instance
          .collection('tourists')
          .snapshots()
          .length;
      numberOfTourist = tourDoc;

      final int tourGuideDoc = await FirebaseFirestore.instance
          .collection('tourGuides')
          .snapshots()
          .length;
      numberOfTourGuide = tourGuideDoc;

      setState(() {
        isLoading = false;
      });
      setState(() {});
    } catch (e) {
      Utils.showSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          title: const Text('Home'),
          backgroundColor: AppTheme.mainAppBar,
          centerTitle: true,
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    if (FirebaseAuth.instance.currentUser == null) {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('No User Logged'),
                          // content: const Text(
                          //     'Login first in order to make a request.'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: const <Widget>[
                                Text('Please Login first.'),
                                Text('Profile -> Login/Sign Up'),
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context, 'OK');
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      Navigator.pushNamed(context, '/chatroom_list');
                    }
                  },
                  child: const Icon(Icons.message),
                )),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'There are ${numberOfTourist.toString()} tourists using the app! Join now.'),
                  ],
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        'There are ${numberOfTourGuide.toString()} tour guide using the app! Join now.'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
