import 'package:travel_guide_tourist/imports.dart';

import '../routes/verify_ic_view.dart';
import 'admin_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var touristData = {};
  bool isAdmin = false;
  bool isLoading = false;

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
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        var collectionRef = FirebaseFirestore.instance.collection('admins');
        var doc = await collectionRef.doc(currentUser.uid).get();
        if (doc.exists) {
          isAdmin = true;
        }
      }

      if (!isAdmin) {
        var touristSnap = await FirebaseFirestore.instance
            .collection('tourists')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

        touristData = touristSnap.data()!;
      }
      setState(() {
        isLoading = false;
      });
      setState(() {});
    } catch (e) {
      // Utils.showSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    if (isAdmin) {
      return const AdminProfileScreen();
    } else {
      return isLoading ? LoadingView() : GestureDetector(
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
          title: const Text('Profile'),
          backgroundColor: AppTheme.mainAppBar,
          centerTitle: true,
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/chatroom_list');
                  },
                  child: const Icon(Icons.message),
                )),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Image.network(
                              touristData['photoUrl'],
                              height: 100,
                              width: 100,
                            ),
                          ),
                          Text("UID: ${touristData['uid']}"),
                          Text("Username: ${touristData['username']}"),
                          Text("Fullname: ${touristData['fullname']}"),
                          Text("IC No: ${touristData['icNumber']}"),
                          Text("IC Verify Status: ${touristData['icVerified']}"),
                          Text("Email: ${touristData['email']}"),
                          Text("Phone No: ${touristData['phoneNumber']}"),
                          Text("Rating: ${touristData['rating']}"),
                          Text("Description: ${touristData['description']}"),
                        ]),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  // style: ElevatedButton.styleFrom(
                  //   minimumSize: const Size.fromHeight(50),
                  // ),
                  icon: const Icon(
                    Icons.edit,
                    // size: 32,
                  ),
                  label: const Text(
                    'Edit Profile',
                    // style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () async {
                    bool changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfile(),
                      ),
                    );
                    changed ? getData() : Container();
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  ///TODO: Submit IC
                  icon: const Icon(
                    Icons.edit,
                    // size: 32,
                  ),
                  label: const Text(
                    'Submit Verify IC',
                    // style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () async {
                    bool changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerifyIcView(),
                      ),
                    );
                    changed ? getData() : Container();
                  },
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  icon: const Icon(Icons.arrow_back, size: 32),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    }
  }
}
