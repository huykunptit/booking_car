import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/dio_provider.dart';

final carListParamsProvider = StateProvider<CarListParams>((ref) => const CarListParams());

final carListProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.read(dioProvider);
  final params = ref.watch(carListParamsProvider);

  final queryParameters = <String, dynamic>{
    'onlyAvailable': params.onlyAvailable,
    'page': 0,
    'size': 20,
  };
  if (params.brand.trim().isNotEmpty) queryParameters['brand'] = params.brand.trim();
  if (params.name.trim().isNotEmpty) queryParameters['name'] = params.name.trim();
  if (params.location.trim().isNotEmpty) queryParameters['location'] = params.location.trim();
  if (params.minPrice != null) queryParameters['minPrice'] = params.minPrice;
  if (params.maxPrice != null) queryParameters['maxPrice'] = params.maxPrice;
  if (params.seats.isNotEmpty) queryParameters['seats'] = params.seats;

  final response = await dio.get('/api/cars', queryParameters: queryParameters);
  final data = response.data['data'] as Map<String, dynamic>;
  final content = data['content'] as List<dynamic>;
  return content.cast<Map<String, dynamic>>();
});

class CarListParams {
  final String brand;
  final String name;
  final String location;
  final bool onlyAvailable;
  final double? minPrice;
  final double? maxPrice;
  final List<int> seats;

  const CarListParams({
    this.brand = '',
    this.name = '',
    this.location = '',
    this.onlyAvailable = true,
    this.minPrice,
    this.maxPrice,
    this.seats = const [],
  });

  CarListParams copyWith({
    String? brand,
    String? name,
    String? location,
    bool? onlyAvailable,
    double? minPrice,
    double? maxPrice,
    List<int>? seats,
  }) {
    return CarListParams(
      brand: brand ?? this.brand,
      name: name ?? this.name,
      location: location ?? this.location,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      seats: seats ?? this.seats,
    );
  }
}

class CarListScreen extends ConsumerStatefulWidget {
  const CarListScreen({super.key});

  @override
  ConsumerState<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends ConsumerState<CarListScreen> {
  final _brandController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final minPrice = double.tryParse(_minPriceController.text.trim());
    final maxPrice = double.tryParse(_maxPriceController.text.trim());
    ref.read(carListParamsProvider.notifier).state = CarListParams(
      brand: _brandController.text,
      name: _nameController.text,
      location: _locationController.text,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    ref.invalidate(carListProvider);
  }

  void _resetFilters() {
    _brandController.clear();
    _nameController.clear();
    _locationController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    ref.read(carListParamsProvider.notifier).state = const CarListParams();
    ref.invalidate(carListProvider);
  }

  @override
  Widget build(BuildContext context) {
    final carsAsync = ref.watch(carListProvider);
    final params = ref.watch(carListParamsProvider);

    _brandController.text = params.brand;
    _nameController.text = params.name;
    _locationController.text = params.location;
    _minPriceController.text = params.minPrice?.toString() ?? '';
    _maxPriceController.text = params.maxPrice?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Xe khả dụng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text('Bộ lọc tìm xe'),
              children: [
                TextField(controller: _brandController, decoration: const InputDecoration(labelText: 'Hãng xe')),
                const SizedBox(height: 8),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Tên xe')),
                const SizedBox(height: 8),
                TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Khu vực')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _minPriceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá tối thiểu'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: _maxPriceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá tối đa'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(onPressed: _applyFilters, child: const Text('Áp dụng')),
                    const SizedBox(width: 12),
                    OutlinedButton(onPressed: _resetFilters, child: const Text('Reset')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: carsAsync.when(
              data: (cars) => RefreshIndicator(
                onRefresh: () async => ref.invalidate(carListProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cars.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    final price = car['pricePerDay']?.toString() ?? '0';
                    final location = car['location']?.toString() ?? 'Chưa có vị trí';
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.push('/cars/${car['id']}'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${car['brand'] ?? ''} ${car['name'] ?? ''}', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(location),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Chip(label: Text('${car['seats'] ?? '-'} chỗ')),
                                  Chip(label: Text('⭐ ${car['averageRating'] ?? 0}')),
                                  Chip(label: Text('$price / ngày')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Không tải được danh sách xe: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
