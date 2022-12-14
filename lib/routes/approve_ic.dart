import 'package:travel_guide_tourist/imports.dart';
import '../models/verity_ic.dart';
import '../routes/verify_ic_view.dart';

class ApproveIC extends StatefulWidget {
  final List<String> touristList;

  const ApproveIC({
    Key? key,
    required this.touristList,
  }) : super(key: key);

  @override
  State<ApproveIC> createState() => _ApproveICState();
}

class _ApproveICState extends State<ApproveIC> {
  bool isLoading = false;
  List<String> touristList = [];

  @override
  void initState() {
    super.initState();
  }



  Widget buildVerifyIc(VerifyIc verifyIc) => Card(
      child: ListTile(
        onTap: () {
          ///pass arguments to route
          Navigator.pushNamed(context, '/ic_detail', arguments: {
            "verifyIcId": verifyIc.verifyIcId,
            "ownerId": verifyIc.ownerId,
            "icFrontPic": verifyIc.icFrontPic,
            "icBackPic": verifyIc.icBackPic,
            "icHoldPic": verifyIc.icHoldPic,
            "status": verifyIc.status,
          });
        },
        title: Text(verifyIc.ownerId),
        subtitle: Text(verifyIc.status),
      ),
    );

  Stream<List<VerifyIc>> readVerifyIc() => FirebaseFirestore.instance
      .collection('icVerifications')
      .where('ownerId', whereIn: widget.touristList)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => VerifyIc.fromJson(doc.data())).toList());

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    {
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
                  title: const Text('IC Verification List'),
                  backgroundColor: AppTheme.mainAppBar,
                  centerTitle: true,
                ),
                body: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<List<VerifyIc>>(
                      stream: readVerifyIc(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong! ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          final verifyIc = snapshot.data!;
                          if (verifyIc.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(5),
                              child: Text('Empty'),
                            );
                          }
                          return ListView(
                            children: verifyIc.map(buildVerifyIc).toList(),
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
              ),
            );
    }
  }
}
