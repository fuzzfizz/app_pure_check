import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../controllers/scanner_controller.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    // Start scanning when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
       ref.read(scannerControllerProvider.notifier).startScanning();
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final state = ref.read(scannerControllerProvider);
    if (!state.isScanning || state.isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    // Process barcode
    ref.read(scannerControllerProvider.notifier).processBarcode(code);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes (errors or routing)
    ref.listen(scannerControllerProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}')),
        );
      }

      if (next.shouldRouteToManualEntry) {
         context.pushReplacement('/manual-entry', extra: {
           'barcode': next.scannedBarcode,
           'prefilledData': next.prefilledData,
           'is_verification': next.prefilledData != null,
         });
         ref.read(scannerControllerProvider.notifier).resetRouting();
      }

      if (next.shouldRouteToProductReview) {
         context.pushReplacement('/manual-entry', extra: { // Using manual entry for review for now, or separate review screen
           'barcode': next.scannedBarcode,
           'product': next.foundProduct,
           'is_review': true,
         });
         ref.read(scannerControllerProvider.notifier).resetRouting();
      }

      if (next.shouldRouteToAnalysis) {
         context.pushReplacement('/analysis', extra: {
           'barcode': next.scannedBarcode,
           'name': next.analysisResult != null ? 'Product' : 'Analyzed Product',
           'ingredientsText': ' ', // Not needed as Edge Function fetches OBF
         });
         ref.read(scannerControllerProvider.notifier).resetRouting();
      }
    });

    final state = ref.watch(scannerControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Product Barcode')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),
          if (state.isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Looking up product...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
