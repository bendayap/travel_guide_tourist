import 'package:travel_guide_tourist/imports.dart';
import '../models/verity_ic.dart';
import '../routes/verify_ic_view.dart';

class IcDetail extends StatefulWidget {
  const IcDetail({
    Key? key,
  }) : super(key: key);

  @override
  State<IcDetail> createState() => _IcDetailState();
}

class _IcDetailState extends State<IcDetail> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);

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
                    child: Column(
                      children: [
                        const Text('Front IC Picture'),
                        Image.network(data['icFrontPic'], height: 150, width: 400),
                        const SizedBox(height: 10),
                        const Text('Front Back Picture'),
                        Image.network(data['icBackPic'], height: 150, width: 200),
                        const SizedBox(height: 10),
                        const Text('Front Hold Picture'),
                        Image.network(data['icHoldPic'], height: 150, width: 200),

                        ElevatedButton(
                            onPressed: () async {
                              await approveIc(data['ownerId']);
                            },
                            child: const Text('Approve'))
                      ],
                    )),
              ),
            );
    }
  }

  approveIc(String ownerId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final docIC =
    FirebaseFirestore.instance.collection('icVerifications').doc('ic_$ownerId');
    docIC.update({
      'status': 'Approved',
    });

    final docTourist =
    FirebaseFirestore.instance.collection('tourists').doc(ownerId);
    docTourist.update({
      'icVerified': true,
    });
    setState(() {});

    Utils.showSnackBarSuccess('Ic Approved');
    navigatorKey.currentState!.pop();
    navigatorKey.currentState!.pop();
  }
}
