import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';

final carTrackingHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, carId) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/api/cars/$carId/tracking/history');
  final data = response.data['data'] as List<dynamic>;
  return data.cast<Map<String, dynamic>>();
});

class CarTrackingScreen extends ConsumerWidget {
  const CarTrackingScreen({super.key, required this.carId});

  final String carId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(carTrackingHistoryProvider(carId));
    return Scaffold(
      appBar: AppBar(title: const Text('Theo dõi xe')),
      body: historyAsync.when(
        data: (history) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = history[index];
            return Card(
              child: ListTile(
                leading: Icon(item['current'] == true ? Icons.my_location : Icons.location_on_outlined),
                title: Text(item['address']?.toString() ?? 'Không có địa chỉ'),
                subtitle: Text('Tọa độ: ${item['latitude'] ?? '-'}, ${item['longitude'] ?? '-'}\nCập nhật: ${item['updatedAt'] ?? '-'}'),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Không tải được lịch sử tracking: $e')),
      ),
    );
  }
}
