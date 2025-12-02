// lib/screens/certificate_results_screen.dart

import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../models/certificate_model.dart';
import 'pdf_viewer_screen.dart';
import '../utils/file_downloader.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate Details'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (certificates.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                for (var cert in certificates) {
                  await _downloadCertificate(context, cert);
                }
              },
              tooltip: 'Download All',
            ),
        ],
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
                  onViewPdf: () => _viewPdf(context, cert),
                  onDownloadPdf: () => _downloadCertificate(context, cert),
                );
              },
            ),
    );
  }

  void _viewPdf(BuildContext context, Certificate certificate) {
    final apiService = ApiService();
    final pdfUrl = apiService.getPdfDownloadUrl(certificate.fileUrl);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(
          pdfUrl: pdfUrl,
          fileName: certificate.title,
        ),
      ),
    );
  }

  Future<void> _downloadCertificate(BuildContext context, Certificate certificate) async {
    final apiService = ApiService();
    final pdfUrl = apiService.getPdfDownloadUrl(certificate.fileUrl);
    final fileName = '${certificate.uin}_${certificate.title}';
    
    await FileDownloader.downloadPdf(
      url: pdfUrl,
      fileName: fileName,
      context: context,
    );
  }
}

class CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onViewPdf;
  final VoidCallback onDownloadPdf;

  const CertificateCard({
    super.key,
    required this.certificate,
    required this.onViewPdf,
    required this.onDownloadPdf,
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
                    icon: const Icon(Icons.remove_red_eye, size: 20),
                    label: const Text(
                      'View PDF',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: onViewPdf,
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
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.download, size: 20),
                    label: const Text(
                      'Download',
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: onDownloadPdf,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Quick Actions Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    _shareCertificate(context);
                  },
                  tooltip: 'Share',
                ),
                IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Print option coming soon')),
                    );
                  },
                  tooltip: 'Print',
                ),
                IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () {
                    _showCertificateInfo(context);
                  },
                  tooltip: 'Info',
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

  void _shareCertificate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing certificate...'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _showCertificateInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Certificate Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${certificate.title}'),
            const SizedBox(height: 8),
            Text('Status: ${certificate.status}'),
            const SizedBox(height: 8),
            Text('Issued: ${certificate.formattedDate}'),
            const SizedBox(height: 8),
            Text('ID: ${certificate.id}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}