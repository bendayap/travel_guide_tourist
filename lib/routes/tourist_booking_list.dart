import 'package:travel_guide_tourist/imports.dart';

class TouristBookingList extends StatelessWidget {
  const TouristBookingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = (ModalRoute.of(context)!.settings.arguments as Map);
    Widget buildBooking(Booking booking) => Card(
          child: ListTile(
            onTap: () async {
              ///pass arguments to route
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingDetail(
                    bookingId: booking.bookingId,
                  ),
                ),
              );
            },
            title: Text('ID: ${booking.bookingId}'),
            subtitle: Text(
                'Date: ${booking.tourDate.toString()}\nPrice: ${booking.price}\nStatus: ${booking.status}'),
          ),
        );

    Stream<List<Booking>> readBookings() => FirebaseFirestore.instance
        .collection('bookings')
        .where('touristId', isEqualTo: data['uid'])
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Booking.fromJson(doc.data())).toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<Booking>>(
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
