import 'package:travel_guide_tourist/imports.dart';

import '../routes/approve_ic.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool isLoading = false;
  List<String> touristList = [];

  @override
  void initState() {
    super.initState();
    _getTourists();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? LoadingView()
        : GestureDetector(
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
                title: const Text('Admin Profile'),
                backgroundColor: AppTheme.mainAppBar,
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Positioned(
                        bottom: 100,
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                              ),
                              child: const Text(
                                'Approve IC verification',
                                style: TextStyle(fontSize: 24),
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ApproveIC(
                                      touristList: touristList,
                                    ),
                                  ),
                                );
                              },
                            ),
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
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  _getTourists() async {
    await FirebaseFirestore.instance
        .collection('tourists')
        .get()
        .then((value) => {
      value.docs.forEach((doc) {
        touristList.add(doc.data()['uid']);
      })
    });
  }
}
