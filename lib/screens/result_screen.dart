// lib/screens/result_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_service.dart';
import '../models/certificate_model.dart';

class VerificationResultScreen extends StatefulWidget {
  final String applicationId;
  final String token;

  const VerificationResultScreen({
    super.key,
    required this.applicationId,
    required this.token,
  });

  @override
  State<VerificationResultScreen> createState() => _VerificationResultScreenState();
}

class _VerificationResultScreenState extends State<VerificationResultScreen> {
  final ApiService _apiService = ApiService();
  List<Certificate> _certificates = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      _certificates = await _apiService.fetchVerificationResult(
        applicationId: widget.applicationId,
        token: widget.token,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _viewPdf(String fileUrl) async {
    final fullUrl = _apiService.getPdfDownloadUrl(fileUrl);
    
    if (await canLaunchUrl(Uri.parse(fullUrl))) {
      await launchUrl(
        Uri.parse(fullUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadCertificates,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 20),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadCertificates,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : _certificates.isEmpty
                  ? const Center(child: Text('No certificates found'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _certificates.length,
                      itemBuilder: (context, index) {
                        final cert = _certificates[index];
                        return CertificateCard(
                          certificate: cert,
                          onViewPdf: () => _viewPdf(cert.fileUrl),
                        );
                      },
                    ),
    );
  }
}

class CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onViewPdf;

  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onViewPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    certificate.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: certificate.isApproved ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    certificate.status,
                    style: TextStyle(
                      color: certificate.isApproved ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Details
            _buildDetailRow('Name', certificate.userName),
            _buildDetailRow('UIN', certificate.uin),
            _buildDetailRow('Mobile', certificate.mobile),
            _buildDetailRow('Issued Date', certificate.formattedDate),
            
            if (certificate.details.isNotEmpty)
              _buildDetailRow('Details', certificate.details),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('View PDF'),
                    onPressed: certificate.fileUrl.isNotEmpty ? onViewPdf : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (certificate.fileUrl.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: onViewPdf,
                    tooltip: 'Download PDF',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}