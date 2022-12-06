import 'imports.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
  // runApp(
  //   MultiProvider(providers: [
  //     ChangeNotifierProvider(create: (_) => AuthProvider(),),
  //   ],
  //     child: MyApp(),
  //   ),
  // );
}

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Travel Guide Tourist Subsystem';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          scaffoldMessengerKey: Utils.messengerKey,
          navigatorKey: navigatorKey,
          title: _title,
          routes: {
            '/tour_guide_list': (context) => const TourGuideList(),
            '/tour_guide_detail': (context) => const TourGuideDetail(),
            '/tour_package_detail': (context) => const TourPackageDetail(),
            '/request_booking': (context) => const RequestBooking(),
            '/tour_guide_nearby': (context) => const TourGuideNearby(),
            '/tour_guide_nearby_detail': (context) => const TourGuideNearbyDetail(),
            '/tourist_booking_list': (context) => const TouristBookingList(),
            '/booking_detail': (context) => const BookingDetail(),
            '/feedback': (context) => const FeedbackToTourGuide(),
            // '/login_screen': (context) => const LoginScreen(),
            // '/signup_screen': (context) => const SignupScreen(),
          },
          home: const MyStatefulWidget(),
        ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final screens = [
    const HomePage(),
    const InstantOrderPage(),
    const BookingPage(),
    WalletPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black, width: 2.0))),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          currentIndex: _selectedIndex,
          unselectedItemColor: Colors.amber[800],
          selectedItemColor: Colors.black,
          iconSize: 30,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Instant Order',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wallet),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
