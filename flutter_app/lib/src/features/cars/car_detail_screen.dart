import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/dio_provider.dart';

final carDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, carId) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/api/cars/$carId');
  final data = response.data['data'] as Map<String, dynamic>;
  return data;
});

final carTrackingProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, carId) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/api/cars/$carId/tracking');
  final data = response.data['data'] as Map<String, dynamic>;
  return data;
});

class CarDetailScreen extends ConsumerWidget {
  const CarDetailScreen({super.key, required this.carId});

  final String carId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final carAsync = ref.watch(carDetailProvider(carId));
    final trackingAsync = ref.watch(carTrackingProvider(carId));
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết xe')),
      body: carAsync.when(
        data: (car) {
          final location = car['location'] ?? 'Chưa cập nhật';
          final imageUrl = car['imageUrl'];
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(carDetailProvider(carId));
              ref.invalidate(carTrackingProvider(carId));
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (imageUrl != null && imageUrl.toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      imageUrl,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage(context),
                    ),
                  )
                else
                  _placeholderImage(context),
                const SizedBox(height: 16),
                Text('${car['brand']} ${car['name']}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(label: '${car['seats']} chỗ'),
                    _InfoChip(label: '${car['transmission'] ?? ''}'),
                    _InfoChip(label: '${car['fuelType'] ?? ''}'),
                    _InfoChip(label: '${car['status'] ?? ''}'),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Giá thuê', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('${car['pricePerDay']} / ngày'),
                        const SizedBox(height: 16),
                        Text('Địa điểm', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(location.toString()),
                        if (car['latitude'] != null && car['longitude'] != null) ...[
                          const SizedBox(height: 8),
                          Text('Tọa độ: ${car['latitude']}, ${car['longitude']}'),
                        ],
                        const SizedBox(height: 16),
                        Text('Đánh giá', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('⭐ ${car['averageRating'] ?? 0} • ${car['reviewCount'] ?? 0} đánh giá'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                trackingAsync.when(
                  data: (tracking) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vị trí hiện tại', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(tracking['address']?.toString() ?? 'Chưa cập nhật'),
                          const SizedBox(height: 8),
                          Text('Tọa độ: ${tracking['latitude'] ?? '-'}, ${tracking['longitude'] ?? '-'}'),
                          const SizedBox(height: 8),
                          Text('Tốc độ: ${tracking['speedKmh'] ?? '-'} km/h'),
                          const SizedBox(height: 8),
                          Text('Cập nhật: ${tracking['updatedAt'] ?? '-'}'),
                        ],
                      ),
                    ),
                  ),
                  loading: () => const Card(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                  error: (e, _) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Không tải được tracking: $e'))),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => context.push('/cars/$carId/book'),
                  icon: const Icon(Icons.event_available),
                  label: const Text('Đặt xe ngay'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Không tải được chi tiết xe: $e')),
      ),
    );
  }

  Widget _placeholderImage(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(Icons.directions_car_rounded, size: 72),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}
