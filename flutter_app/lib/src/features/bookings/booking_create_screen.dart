import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/dio_provider.dart';

class BookingCreateScreen extends ConsumerStatefulWidget {
  const BookingCreateScreen({super.key, required this.carId});

  final String carId;

  @override
  ConsumerState<BookingCreateScreen> createState() => _BookingCreateScreenState();
}

class _BookingCreateScreenState extends ConsumerState<BookingCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTimeRange? _selectedRange;
  bool _loading = false;

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _selectedRange,
    );
    if (range != null) {
      setState(() => _selectedRange = range);
    }
  }

  Future<void> _submit() async {
    if (_selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày thuê')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/api/bookings', data: {
        'carId': int.parse(widget.carId),
        'startDate': _selectedRange!.start.toIso8601String().split('T').first,
        'endDate': _selectedRange!.end.toIso8601String().split('T').first,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đặt xe thành công')));
        context.go('/bookings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể tạo booking: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rangeText = _selectedRange == null
        ? 'Chưa chọn'
        : '${_selectedRange!.start.toLocal().toString().split(' ').first} → ${_selectedRange!.end.toLocal().toString().split(' ').first}';

    return Scaffold(
      appBar: AppBar(title: const Text('Tạo booking')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Xe #${widget.carId}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.date_range),
                    title: const Text('Thời gian thuê'),
                    subtitle: Text(rangeText),
                    trailing: TextButton(onPressed: _pickDates, child: const Text('Chọn ngày')),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Xác nhận đặt xe'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
