// lib/screens/pdf_viewer_screen.dart

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.fileName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              _pdfViewerController.zoomLevel = 2.0;
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              _pdfViewerController.zoomLevel = 1.0;
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Download functionality already in certificate screen
            },
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.pdfUrl,
        controller: _pdfViewerController,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          setState(() {
            _isLoading = false;
          });
        },
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load PDF: ${details.error}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
      bottomNavigationBar: _isLoading
          ? const LinearProgressIndicator()
          : Container(
              height: 50,
              color: Colors.grey.shade100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.first_page),
                    onPressed: () {
                      _pdfViewerController.jumpToPage(1);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      _pdfViewerController.previousPage();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      _pdfViewerController.nextPage();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.last_page),
                    onPressed: () {
                      _pdfViewerController.jumpToPage(
                        _pdfViewerController.pageCount,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}