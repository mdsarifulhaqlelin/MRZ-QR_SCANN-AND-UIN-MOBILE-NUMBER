// lib/screens/certificate_results_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_service.dart';
import '../models/certificate_model.dart';

class CertificateResultsScreen extends StatelessWidget {
  final List<Certificate> certificates;
  final String applicationId;
  final String token;

  const CertificateResultsScreen({
    super.key,
    required this.certificates,
    required this.applicationId,
    required this.token,
  });

  Future<void> _viewPdf(String fileUrl) async {
    final apiService = ApiService();
    final fullUrl = apiService.getPdfDownloadUrl(fileUrl);
    
    print('📄 Opening PDF: $fullUrl');
    
    if (await canLaunchUrl(Uri.parse(fullUrl))) {
      await launchUrl(
        Uri.parse(fullUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $fullUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate Details'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: certificates.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.document_scanner_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No certificates found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final cert = certificates[index];
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
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    certificate.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: certificate.status.toLowerCase() == 'approved'
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: certificate.status.toLowerCase() == 'approved'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  child: Text(
                    certificate.status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: certificate.status.toLowerCase() == 'approved'
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 16),

            // Certificate Details
            _buildDetailRow('Name:', certificate.userName),
            _buildDetailRow('UIN:', certificate.uin),
            _buildDetailRow('Mobile:', certificate.mobile),
            _buildDetailRow('Issue Date:', certificate.formattedDate),
            
            if (certificate.details.isNotEmpty && certificate.details != 'N/A')
              _buildDetailRow('Details:', certificate.details),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf, size: 20),
                    label: const Text(
                      'View PDF Certificate',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: certificate.fileUrl.isNotEmpty ? onViewPdf : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (certificate.fileUrl.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.download, size: 24),
                    onPressed: onViewPdf,
                    tooltip: 'Download PDF',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      padding: const EdgeInsets.all(12),
                    ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}