import 'package:travel_guide_tourist/imports.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {

  @override
  void initState() {
    ///TODO: Implement statement
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.mainBackground,
    appBar: AppBar(
      title: const Text('Wallet'),
      backgroundColor: AppTheme.mainAppBar,
      centerTitle: true,
    ),
    body: const Center(child: Text('Wallet', style: TextStyle(fontSize: 60))),
  );
}
