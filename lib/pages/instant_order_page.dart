import 'package:travel_guide_tourist/imports.dart';
import 'instant_order_screen.dart';

class InstantOrderPage extends StatelessWidget {
  const InstantOrderPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong!'));
        } else if (snapshot.hasData) {
          return const InstantOrderScreen();
        } else {
          return const InstantOrderScreen();
        }
      },
    ),
  );
}
