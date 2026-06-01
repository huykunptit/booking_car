import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';

final bookingDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, bookingId) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/api/bookings/$bookingId');
  final data = response.data['data'] as Map<String, dynamic>;
  return data;
});

class BookingDetailScreen extends ConsumerWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    try {
      final dio = ref.read(dioProvider);
      await dio.put('/api/bookings/$bookingId/cancel');
      ref.invalidate(bookingDetailProvider(bookingId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy booking')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể hủy booking: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết booking')),
      body: bookingAsync.when(
        data: (booking) {
          final status = booking['status']?.toString() ?? '';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${booking['carBrand']} ${booking['carName']}', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text('Biển số: ${booking['carLicensePlate'] ?? ''}'),
                      const SizedBox(height: 8),
                      Text('Thời gian: ${booking['startDate']} → ${booking['endDate']}'),
                      const SizedBox(height: 8),
                      Text('Tổng tiền: ${booking['totalPrice']}'),
                      const SizedBox(height: 8),
                      Text('Trạng thái: $status'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (status == 'PENDING')
                FilledButton.icon(
                  onPressed: () => _cancel(context, ref),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Hủy booking'),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Không tải được chi tiết booking: $e')),
      ),
    );
  }
}
