import 'package:core_localization/generated/l10n.dart';
import 'package:design_system/colors/app_colors.dart';
import 'package:design_system/constants/app_borders.dart';
import 'package:design_system/constants/app_spacers.dart';
import 'package:design_system/theme/app_brand_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Camera view that reads a policy's QR code, with a gallery fallback for a
/// policy kept as a screenshot or PDF page. Resolves to the QR's text, or
/// null when dismissed.
Future<String?> showInsuranceQrScanner(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.brandTheme.surfaceBg,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => const _InsuranceQrScannerSheet(),
  );
}

class _InsuranceQrScannerSheet extends StatefulWidget {
  const _InsuranceQrScannerSheet();

  @override
  State<_InsuranceQrScannerSheet> createState() => _InsuranceQrScannerSheetState();
}

class _InsuranceQrScannerSheetState extends State<_InsuranceQrScannerSheet> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish(BarcodeCapture? capture) {
    final value = capture?.barcodes.map((code) => code.rawValue).whereType<String>().firstOrNull;
    if (_done || value == null) return;
    _done = true;
    Navigator.of(context).pop(value);
  }

  Future<void> _pickFromGallery() async {
    final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (photo == null || !mounted) return;
    _finish(await _controller.analyzeImage(photo.path));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).insurance_scan_qr_hint,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            AppSpacers.verticalMedium,
            ClipRRect(
              borderRadius: AppBorders.radius16,
              child: SizedBox(
                height: 320,
                child: MobileScanner(
                  controller: _controller,
                  onDetect: _finish,
                  errorBuilder: (context, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        S.of(context).insurance_scan_camera_error,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AppSpacers.verticalMedium,
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(S.of(context).insurance_scan_from_gallery),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
