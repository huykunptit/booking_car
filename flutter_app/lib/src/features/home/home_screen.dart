import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Booking'),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(authControllerProvider).logout();
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Khám phá xe'),
                subtitle: const Text('Tìm xe khả dụng, xem chi tiết và đặt xe'),
                onTap: () => context.go('/cars'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Lịch sử booking'),
                subtitle: const Text('Theo dõi các đơn thuê xe của bạn'),
                onTap: () => context.go('/bookings'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Track xe'),
                subtitle: const Text('Xem vị trí hiện tại và lịch sử di chuyển'),
                onTap: () => context.go('/cars/1/tracking'),
              ),
            ),
            const SizedBox(height: 24),
            const Expanded(
              child: Center(child: Text('Trang chủ đang được mở rộng theo roadmap')),
            ),
          ],
        ),
      ),
    );
  }
}
