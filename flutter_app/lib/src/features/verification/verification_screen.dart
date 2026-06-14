import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../core/network/dio_provider.dart';
import '../../core/theme/app_theme.dart';

final verificationStatusProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final response = await ref.read(dioProvider).get('/api/verification/status');
  return response.data['data'] as Map<String, dynamic>;
});

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  bool _uploadingCccd = false;
  bool _uploadingLicense = false;
  final _picker = ImagePicker();

  Future<void> _pickAndUpload(String type) async {
    final isLicense = type == 'license';
    setState(() {
      if (isLicense) {
        _uploadingLicense = true;
      } else {
        _uploadingCccd = true;
      }
    });
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;

      final dio = ref.read(dioProvider);
      final FormData formData;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        formData = FormData.fromMap({
          'image': MultipartFile.fromBytes(bytes, filename: picked.name),
        });
      } else {
        formData = FormData.fromMap({
          'image': await MultipartFile.fromFile(picked.path, filename: picked.name),
        });
      }

      final endpoint = isLicense ? '/api/verification/license' : '/api/verification/cccd';
      final response = await dio.post(endpoint, data: formData);
      final data = response.data['data'] as Map<String, dynamic>;

      if (mounted) {
        ref.invalidate(verificationStatusProvider);
        final ok = data['ocrSuccess'] == true;
        final spoofed = data['isSpoofed'] == true;
        final msg = spoofed
            ? 'Phát hiện giấy tờ giả mạo!'
            : ok
                ? 'Xác minh thành công!'
                : 'Không nhận dạng được ảnh, vui lòng chụp lại rõ hơn';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: spoofed ? Colors.red : ok ? Colors.green : Colors.orange,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          if (isLicense) {
          _uploadingLicense = false;
        } else {
          _uploadingCccd = false;
        }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(verificationStatusProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                padding: const EdgeInsets.fromLTRB(24, 88, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Xác minh danh tính',
                      style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Upload CCCD & Bằng lái xe để thuê xe dễ dàng',
                      style: tt.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            title: const Text('Xác minh danh tính'),
          ),

          statusAsync.when(
            data: (statusData) => SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _OverallBadge(verificationStatus: statusData['status']?.toString() ?? 'UNVERIFIED'),
                  const SizedBox(height: 24),

                  _DocCard(
                    icon: Icons.badge_rounded,
                    title: 'Căn cước công dân (CCCD)',
                    subtitle: 'Chụp mặt trước CCCD rõ nét, đủ 4 góc',
                    verified: statusData['cccdVerified'] == true,
                    spoofed: statusData['cccdSpoofed'] == true,
                    uploading: _uploadingCccd,
                    extractedInfo: statusData['cccdVerified'] == true
                        ? '${statusData['fullName']}  •  ${statusData['cccdNumber']}'
                        : null,
                    onUpload: () => _pickAndUpload('cccd'),
                  ),
                  const SizedBox(height: 16),

                  _DocCard(
                    icon: Icons.drive_eta_rounded,
                    title: 'Giấy phép lái xe (GPLX)',
                    subtitle: 'Chụp mặt trước bằng lái rõ nét, đủ 4 góc',
                    verified: statusData['licenseVerified'] == true,
                    spoofed: statusData['licenseSpoofed'] == true,
                    uploading: _uploadingLicense,
                    extractedInfo: statusData['licenseVerified'] == true
                        ? 'Hạng ${statusData['licenseClass'] ?? '?'}'
                        : null,
                    onUpload: () => _pickAndUpload('license'),
                  ),
                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.tips_and_updates_rounded, color: cs.primary, size: 18),
                          const SizedBox(width: 8),
                          Text('Lưu ý khi chụp ảnh',
                              style: tt.labelLarge?.copyWith(color: cs.primary)),
                        ]),
                        const SizedBox(height: 10),
                        for (final tip in const [
                          'Đặt giấy tờ trên nền phẳng, ánh sáng đều',
                          'Chụp đủ 4 góc, không bị che khuất hay phản sáng',
                          'Ảnh tối thiểu 300KB, không bị mờ hay nghiêng',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('• ', style: tt.bodySmall?.copyWith(color: cs.primary)),
                                Expanded(child: Text(tip, style: tt.bodySmall)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline_rounded, size: 48),
                  const SizedBox(height: 12),
                  Text('Lỗi: $e'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(verificationStatusProvider),
                    child: const Text('Thử lại'),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverallBadge extends StatelessWidget {
  const _OverallBadge({required this.verificationStatus});
  final String verificationStatus;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final IconData icon;
    final Color color;
    final String label;

    switch (verificationStatus) {
      case 'VERIFIED':
        icon = Icons.verified_rounded;
        color = Colors.green;
        label = 'Đã xác minh đầy đủ';
      case 'PENDING':
        icon = Icons.pending_rounded;
        color = Colors.orange;
        label = 'Đã xác minh một phần';
      case 'REJECTED':
        icon = Icons.cancel_rounded;
        color = cs.error;
        label = 'Xác minh thất bại — giấy tờ không hợp lệ';
      default:
        icon = Icons.info_outline_rounded;
        color = cs.outline;
        label = 'Chưa xác minh';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label,
              style: tt.titleSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _DocCard extends StatelessWidget {
  const _DocCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.verified,
    required this.spoofed,
    required this.uploading,
    required this.onUpload,
    this.extractedInfo,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool verified;
  final bool spoofed;
  final bool uploading;
  final String? extractedInfo;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final Color stateColor;
    final String stateLabel;
    if (spoofed) {
      stateColor = cs.error;
      stateLabel = 'Giả mạo';
    } else if (verified) {
      stateColor = Colors.green;
      stateLabel = 'Đã xác minh';
    } else {
      stateColor = cs.outline;
      stateLabel = 'Chưa xác minh';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        boxShadow: [AppTheme.softShadow],
        border: verified ? Border.all(color: Colors.green.withValues(alpha: 0.3)) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: cs.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: tt.bodySmall?.copyWith(color: cs.outline),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(stateLabel,
                style: tt.labelSmall?.copyWith(color: stateColor, fontWeight: FontWeight.w700)),
          ),
        ]),
        if (extractedInfo != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(extractedInfo!,
                    style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
              ),
            ]),
          ),
        ],
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: uploading ? null : onUpload,
            icon: uploading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(verified ? Icons.refresh_rounded : Icons.upload_rounded, size: 18),
            label: Text(uploading
                ? 'Đang xử lý...'
                : verified
                    ? 'Upload lại'
                    : 'Chọn ảnh từ thư viện'),
          ),
        ),
      ]),
    );
  }
}
