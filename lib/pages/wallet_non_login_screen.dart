import 'package:travel_guide_tourist/imports.dart';

class WalletNonLoginScreen extends StatefulWidget {
  const WalletNonLoginScreen({super.key});

  @override
  State<WalletNonLoginScreen> createState() => _WalletNonLoginScreenState();
}

class _WalletNonLoginScreenState extends State<WalletNonLoginScreen> {
  @override
  void initState() {
    super.initState();
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: AppTheme.mainAppBar,
        centerTitle: true,
      ),
      body: Stack(
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
              decoration:
                  BoxDecoration(color: Theme.of(context).colorScheme.secondary
                      // gradient: LinearGradient(
                      //     begin: Alignment.centerLeft,
                      //     end: Alignment.centerRight,
                      //     colors: [AppTheme.primary, AppTheme.secondary])
                      ),
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
                      "RM 0.00",
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
              //     child: Column(
              //       children: [
              //         const SizedBox(height: 60),
              //         Container(
              //             child: Column(
              //           children: [
              //             GestureDetector(
              //                 onTap: () {
              //                   // => Navigator.of(context).push(
              //                   // MaterialPageRoute(
              //                   // builder: (context) => const WalletStatisticView(),
              //                   // ),
              //                   // ),
              //                 },
              //                 child: selectionView(
              //                     Icons.area_chart, "Wallet Statistic")),
              //             const Divider(
              //               height: 1,
              //               thickness: 1,
              //               indent: 0,
              //               endIndent: 0,
              //               color: Colors.grey,
              //             ),
              //             GestureDetector(
              //                 onTap: () {
              //                   // => Navigator.of(context).push(
              //                   //   MaterialPageRoute(
              //                   //     builder: (context) =>
              //                   //     const TransactionStatisticView(),
              //                   //   ),
              //                   // ),
              //                 },
              //                 child: selectionView(Icons.line_axis_outlined,
              //                     "Transaction Statistic")),
              //           ],
              //         )),
              //       ],
              //     ),
            ),
          ),
          Positioned(
            top: 120,
            child: Container(
              height: 100,
              width: width * 0.9,
              margin: EdgeInsets.symmetric(horizontal: width * 0.05),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('User Not Logged In.'),
                            content: const Text(
                                'Login first to use eWallet.\nGO to Profile -> Login/Sign Up'),
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
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('User Not Logged In.'),
                            content: const Text(
                                'Login first to use eWallet.\nGO to Profile -> Login/Sign Up'),
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
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('User Not Logged In.'),
                            content: const Text(
                                'Login first to use eWallet.\nGO to Profile -> Login/Sign Up'),
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
    );
  }
}
