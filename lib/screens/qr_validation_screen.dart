// lib/screens/qr_validation_screen.dart (COMPLETE FIXED VERSION)

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../api/api_service.dart';
import 'certificate_results_screen.dart';

class QrValidationScreen extends StatefulWidget {
  const QrValidationScreen({super.key});

  @override
  State<QrValidationScreen> createState() => _QrValidationScreenState();
}

class _QrValidationScreenState extends State<QrValidationScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _mobileController = TextEditingController();
  
  String _qrCode = '';
  bool _isLoading = false;
  String _errorMessage = '';
  bool _qrScanned = false;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _startQrScan() async {
    final String? scannedCode = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(
          onDetect: (code) {
            Navigator.pop(context, code);
          },
        ),
      ),
    );

    if (scannedCode != null && scannedCode.isNotEmpty) {
      // Extract QR code from URL if it's a URL
      String extractedQr = scannedCode;
      String? extractedMobile;
      
      try {
        final uri = Uri.tryParse(scannedCode);
        if (uri != null && uri.hasQuery) {
          // Extract qr parameter from URL
          if (uri.queryParameters.containsKey('qr')) {
            extractedQr = uri.queryParameters['qr']!;
          }
          // Extract mobile from URL (mo parameter)
          if (uri.queryParameters.containsKey('mo')) {
            extractedMobile = uri.queryParameters['mo'];
          }
        }
      } catch (e) {
        print('Error parsing QR URL: $e');
      }

      setState(() {
        _qrCode = extractedQr;
        _qrScanned = true;
        _errorMessage = '';
        
        // Auto-fill mobile if extracted from QR
        if (extractedMobile != null && extractedMobile.isNotEmpty) {
          _mobileController.text = extractedMobile;
        }
      });
    }
  }

  Future<void> _validateQr() async {
    final mobile = _mobileController.text.trim();

    if (!_qrScanned) {
      _showError('Please scan QR code first');
      return;
    }

    if (mobile.isEmpty) {
      _showError('Mobile number is required');
      return;
    }

    if (mobile.length != 11 || !mobile.startsWith('01')) {
      _showError('Mobile must be 11 digits starting with 01');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Step 1: Validate QR with mobile
      print('🔍 Validating QR: $_qrCode with mobile: $mobile');
      final validationData = await _apiService.validateWithQr(
        qr: _qrCode,
        mobile: mobile,
      );

      // Step 2: Fetch certificate details
      print('📋 Fetching certificate details...');
      final certificates = await _apiService.fetchVerificationResult(
        applicationId: validationData['applicationId'],
        token: validationData['token'],
      );

      // Step 3: Navigate to results screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CertificateResultsScreen(
              certificates: certificates,
              applicationId: validationData['applicationId'],
              token: validationData['token'],
            ),
          ),
        );
      }
    } catch (e) {
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception: ')) {
        errorMsg = errorMsg.replaceFirst('Exception: ', '');
      }
      _showError(errorMsg);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  void _resetScan() {
    setState(() {
      _qrCode = '';
      _qrScanned = false;
      _mobileController.clear();
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Validation'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Instruction Text
            const Text(
              'Scan QR code and enter mobile number for verification',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // QR Scan Status Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _qrScanned ? Icons.check_circle : Icons.qr_code_scanner,
                      color: _qrScanned ? Colors.green : Colors.blue,
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _qrScanned ? 'QR Code Scanned' : 'Ready to Scan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _qrScanned ? Colors.green : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _qrScanned 
                              ? 'QR data has been captured' 
                              : 'Tap the button below to scan QR code',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Mobile Input
            TextField(
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              maxLength: 11,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                hintText: '01XXXXXXXXX',
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
                counterText: '',
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter 11 digit mobile number starting with 01',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Buttons Section
            Column(
              children: [
                if (!_qrScanned)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _startQrScan,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Scan QR Code',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),

                if (_qrScanned)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _validateQr,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Validate Certificate',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _isLoading ? null : _resetScan,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.blue),
                        ),
                        child: const Text(
                          'Scan Again',
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            // Error Message
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // QR Code Preview
            if (_qrScanned && _qrCode.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Scanned QR Data:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: SelectableText(
                      _qrCode,
                      style: const TextStyle(
                        fontFamily: 'Monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// QR Scanner Page
class QRScannerPage extends StatefulWidget {
  final Function(String) onDetect;
  
  const QRScannerPage({
    super.key,
    required this.onDetect,
  });

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController(
    torchEnabled: false,
    formats: [BarcodeFormat.qrCode],
    facing: CameraFacing.back,
  );

  bool _isScanning = true;
  bool _isTorchOn = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() => _isTorchOn = !_isTorchOn);
              cameraController.toggleTorch();
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!_isScanning) return;
              
              final barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue;
                if (code != null && code.isNotEmpty) {
                  setState(() => _isScanning = false);
                  cameraController.stop();
                  
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (mounted) {
                      widget.onDetect(code);
                    }
                  });
                }
              }
            },
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Camera Error: ${error.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),

          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber, width: 4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              'Align QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}