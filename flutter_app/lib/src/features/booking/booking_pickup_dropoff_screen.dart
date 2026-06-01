import 'package:flutter/material.dart';

class BookingPickupDropoffScreen extends StatelessWidget {
  const BookingPickupDropoffScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn điểm đón/trả')),
      body: Center(
        child: Text('Booking #$bookingId - màn map chọn điểm đón/trả sẽ được kết nối tiếp với map SDK'),
      ),
    );
  }
}
