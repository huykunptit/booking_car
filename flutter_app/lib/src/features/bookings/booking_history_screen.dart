import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';

final bookingHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/api/bookings/my-bookings', queryParameters: {'page': 0, 'size': 20});
  final data = response.data['data'] as Map<String, dynamic>;
  final content = data['content'] as List<dynamic>;
  return content.cast<Map<String, dynamic>>();
});

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử booking')),
      body: bookingsAsync.when(
        data: (bookings) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Card(
              child: ListTile(
                title: Text('${booking['carBrand']} ${booking['carName']}'),
                subtitle: Text('${booking['startDate']} → ${booking['endDate']} • ${booking['status']}'),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Không tải được booking: $e')),
      ),
    );
  }
}
