import 'package:travel_guide_tourist/imports.dart';

import '../routes/booking_detail_view_only.dart';

class AdminBookingScreen extends StatefulWidget {
  const AdminBookingScreen({super.key});

  @override
  State<AdminBookingScreen> createState() => _AdminBookingScreenState();
}

class _AdminBookingScreenState extends State<AdminBookingScreen> {
  bool isLoading = false;
  bool isAdmin = false;

  Widget buildBooking(Booking booking) => Card(
        child: ListTile(
          onTap: () async {
            ///pass arguments to route
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingDetailViewOnly(
                  bookingId: booking.bookingId,
                ),
              ),
            );
          },
          title: Text('ID: ${booking.bookingId}'),
          subtitle: Text('Tourist ID: ${booking.touristId}'
              '\nDate: ${booking.tourDate.toString()}\nPrice: ${booking.price}'),
        ),
      );

  Stream<List<Booking>> readBookings() => FirebaseFirestore.instance
      .collection("bookings")
      .orderBy("touristId", descending: false)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Booking"),
        backgroundColor: AppTheme.mainAppBar,
        centerTitle: true,
      ),
      body: Container(
        child: isLoading
            ? LoadingView()
            : StreamBuilder<List<Booking>>(
                stream: readBookings(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong! ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final booking = snapshot.data!;

                    return ListView(
                      children: booking.map(buildBooking).toList(),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
      ),
    );
  }
}
