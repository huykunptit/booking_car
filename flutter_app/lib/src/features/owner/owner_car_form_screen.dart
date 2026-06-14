import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import '../../core/theme/app_theme.dart';

class OwnerCarFormScreen extends ConsumerStatefulWidget {
  const OwnerCarFormScreen({super.key, this.carId});

  final String? carId;

  @override
  ConsumerState<OwnerCarFormScreen> createState() => _OwnerCarFormScreenState();
}

class _OwnerCarFormScreenState extends ConsumerState<OwnerCarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  String _transmission = 'AUTOMATIC';
  String _fuelType = 'GASOLINE';
  int _seats = 5;
  bool _loading = false;
  bool _fetchingCar = false;

  bool get _isEdit => widget.carId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) _fetchCar();
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _brandCtrl, _modelCtrl, _plateCtrl, _priceCtrl, _locationCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchCar() async {
    setState(() => _fetchingCar = true);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.get('/api/cars/${widget.carId}');
      final car = response.data['data'] as Map<String, dynamic>;
      _nameCtrl.text = car['name']?.toString() ?? '';
      _brandCtrl.text = car['brand']?.toString() ?? '';
      _modelCtrl.text = car['model']?.toString() ?? '';
      _plateCtrl.text = car['licensePlate']?.toString() ?? '';
      _priceCtrl.text = car['pricePerDay']?.toString().split('.').first ?? '';
      _locationCtrl.text = car['location']?.toString() ?? '';
      setState(() {
        _transmission = car['transmission']?.toString() ?? 'AUTOMATIC';
        _fuelType = car['fuelType']?.toString() ?? 'GASOLINE';
        _seats = (car['seats'] as num?)?.toInt() ?? 5;
      });
    } catch (_) {}
    finally {
      if (mounted) setState(() => _fetchingCar = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final dio = ref.read(dioProvider);
      final data = {
        'name': _nameCtrl.text.trim(),
        'brand': _brandCtrl.text.trim(),
        'model': _modelCtrl.text.trim(),
        'licensePlate': _plateCtrl.text.trim(),
        'pricePerDay': double.parse(_priceCtrl.text.trim()),
        'location': _locationCtrl.text.trim(),
        'transmission': _transmission,
        'fuelType': _fuelType,
        'seats': _seats,
      };
      if (_isEdit) {
        await dio.put('/api/owner/cars/${widget.carId}', data: data);
      } else {
        await dio.post('/api/owner/cars', data: data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEdit ? 'Cập nhật xe thành công' : 'Đăng xe thành công')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fetchingCar) {
      return Scaffold(
        appBar: AppBar(title: Text(_isEdit ? 'Chỉnh sửa xe' : 'Đăng xe mới')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Chỉnh sửa xe' : 'Đăng xe mới')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Section(
                title: 'Thông tin cơ bản',
                children: [
                  _Field(ctrl: _nameCtrl, label: 'Tên xe', icon: Icons.directions_car_rounded, required: true),
                  const SizedBox(height: 16),
                  _Field(ctrl: _brandCtrl, label: 'Hãng xe', icon: Icons.business_rounded, required: true),
                  const SizedBox(height: 16),
                  _Field(ctrl: _modelCtrl, label: 'Phiên bản / Model', icon: Icons.info_outline_rounded),
                  const SizedBox(height: 16),
                  _Field(
                    ctrl: _plateCtrl,
                    label: 'Biển số xe',
                    icon: Icons.pin_rounded,
                    required: true,
                    hint: 'VD: 30K-123.45',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Giá & Vị trí',
                children: [
                  _Field(
                    ctrl: _priceCtrl,
                    label: 'Giá thuê / ngày (VNĐ)',
                    icon: Icons.payments_rounded,
                    required: true,
                    numeric: true,
                    hint: 'VD: 800000',
                  ),
                  const SizedBox(height: 16),
                  _Field(
                    ctrl: _locationCtrl,
                    label: 'Khu vực giao xe',
                    icon: Icons.location_on_rounded,
                    required: true,
                    hint: 'VD: Hà Nội, Quận Đống Đa',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _Section(
                title: 'Thông số kỹ thuật',
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _transmission,
                    decoration: const InputDecoration(
                      labelText: 'Hộp số',
                      prefixIcon: Icon(Icons.settings_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'AUTOMATIC', child: Text('Số tự động')),
                      DropdownMenuItem(value: 'MANUAL', child: Text('Số sàn')),
                    ],
                    onChanged: (v) => setState(() => _transmission = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _fuelType,
                    decoration: const InputDecoration(
                      labelText: 'Nhiên liệu',
                      prefixIcon: Icon(Icons.local_gas_station_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'GASOLINE', child: Text('Xăng')),
                      DropdownMenuItem(value: 'DIESEL', child: Text('Dầu diesel')),
                      DropdownMenuItem(value: 'ELECTRIC', child: Text('Điện')),
                      DropdownMenuItem(value: 'HYBRID', child: Text('Hybrid')),
                    ],
                    onChanged: (v) => setState(() => _fuelType = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _seats,
                    decoration: const InputDecoration(
                      labelText: 'Số chỗ ngồi',
                      prefixIcon: Icon(Icons.airline_seat_recline_normal_rounded),
                    ),
                    items: [4, 5, 7, 8, 9]
                        .map((s) => DropdownMenuItem(value: s, child: Text('$s chỗ')))
                        .toList(),
                    onChanged: (v) => setState(() => _seats = v!),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              GradientButton(
                onPressed: _loading ? null : _submit,
                isLoading: _loading,
                child: Text(
                  _isEdit ? 'Lưu thay đổi' : 'Đăng xe',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.required = false,
    this.numeric = false,
    this.hint,
  });

  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool required;
  final bool numeric;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: required
          ? (v) => (v?.trim().isEmpty ?? true) ? 'Vui lòng nhập $label' : null
          : null,
    );
  }
}
