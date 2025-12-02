// lib/screens/uin_validation_screen.dart

import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'certificate_results_screen.dart';

class UinValidationScreen extends StatefulWidget {
  const UinValidationScreen({super.key});

  @override
  State<UinValidationScreen> createState() => _UinValidationScreenState();
}

class _UinValidationScreenState extends State<UinValidationScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _uinController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _uinController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _validateUin() async {
    final uin = _uinController.text.trim();
    final mobile = _mobileController.text.trim();

    // Input validation
    if (uin.isEmpty) {
      _showError('UIN is required');
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
      // Step 1: Validate UIN with mobile
      print('🔍 Validating UIN: $uin with mobile: $mobile');
      final validationData = await _apiService.validateWithUin(
        uin: uin,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UIN & Mobile Validation'),
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
              'Enter UIN and mobile number for certificate verification',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // UIN Input
            TextField(
              controller: _uinController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'UIN (6 digits)',
                hintText: '123456',
                prefixIcon: const Icon(Icons.fingerprint),
                border: const OutlineInputBorder(),
                counterText: '',
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter 6 digit Unique Identification Number',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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

            // Validate Button
            ElevatedButton(
              onPressed: _isLoading ? null : _validateUin,
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
                      'Validate Certificate',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
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

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}