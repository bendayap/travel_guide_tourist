import 'package:travel_guide_tourist/imports.dart';

import 'admin_wallet_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool isLoading = false;
  bool isAdmin = false;
  var eWalletData = {};

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
        var eWalletSnap = await FirebaseFirestore.instance
            .collection('eWallet')
            .doc("ewallet_${FirebaseAuth.instance.currentUser!.uid}")
            .get();

        eWalletData = eWalletSnap.data()!;
      }
      setState(() {
        isLoading = false;
      });
      setState(() {});
    } catch (e) {
      Utils.showSnackBar(e.toString());
    }
  }

  Widget selectionView(IconData icon, String title) {
     return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(),
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 10.0),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (isAdmin) {
      return const AdminWalletScreen();
    } else {
      return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
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
                              Text('Login first in order to make a request.'),
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
      body: Container(
        child: isLoading
            ? LoadingView()
            : Stack(
                fit: StackFit.passthrough,
                children: <Widget>[
                  const SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                  ),
                  Positioned(
                    child: Container(
                      height: 250,
                      padding: const EdgeInsets.symmetric(),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary),
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 30.0),
                            Text(
                              "Available Balance",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.4,
                                height: 0.9,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Text(
                              "RM ${eWalletData["balance"].toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 36,
                                letterSpacing: 0.4,
                                height: 0.9,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 180,
                    child: Container(
                      height: height,
                      width: width,
                      decoration: BoxDecoration(
                        color: AppTheme.mainBackground,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    child: Container(
                      height: 100,
                      width: width * 0.9,
                      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.shadow,
                            offset: const Offset(
                              0.0,
                              1.0,
                            ),
                            blurRadius: 10.0,
                            spreadRadius: 0.5,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () async {
                                // cashIn
                                bool changed = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectBankCard(
                                        action: "Reload",
                                        eWalletId: eWalletData["eWalletId"],
                                        balance: eWalletData["balance"]),
                                  ),
                                );
                                changed ? getData() : Container();
                              },
                              child: Center(
                                child: Column(
                                  children: const [
                                    Icon(
                                      Icons.attach_money_sharp,
                                      size: 35,
                                    ),
                                    Text("Reload"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const VerticalDivider(),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () async {
                                // cashOut
                                bool changed = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectBankCard(
                                        action: "Withdraw",
                                        eWalletId: eWalletData["eWalletId"],
                                        balance: eWalletData["balance"]),
                                  ),
                                );
                                changed ? getData() : Container();
                              },
                              child: Center(
                                child: Column(
                                  children: const [
                                    Icon(
                                      Icons.money_off,
                                      size: 35,
                                    ),
                                    Text("Withdraw"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const VerticalDivider(),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/transaction_list',
                                    arguments: {
                                      'ownerId': FirebaseAuth
                                          .instance.currentUser!.uid,
                                    });
                              },
                              child: Center(
                                child: Column(
                                  children: const [
                                    Icon(
                                      Icons.history,
                                      size: 35,
                                    ),
                                    Text("History"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
    }
  }
}
