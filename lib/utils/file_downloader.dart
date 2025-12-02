// lib/utils/file_downloader.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class FileDownloader {
  static Future<String?> downloadPdf({
    required String url,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      // Step 1: Permission check
      if (Platform.isAndroid) {
        final status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
        
        // Android 13+ এর জন্য
        if (await Permission.manageExternalStorage.request().isGranted) {
          // Allowed
        }
      }

      // Step 2: Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory == null) {
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Step 3: Create file path
      final filePath = '${directory!.path}/$fileName.pdf';
      final file = File(filePath);

      // Step 4: Download file
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Downloading PDF...'),
          backgroundColor: Colors.blue.shade700,
        ),
      );

      final dio = Dio();
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Downloading: $progress%'),
                  backgroundColor: Colors.blue.shade700,
                ),
              );
          }
        },
      );

      // Step 5: Show success message
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('PDF saved to: $filePath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () => openFile(filePath),
            ),
          ),
        );

      return filePath;
    } catch (e) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      return null;
    }
  }

  static Future<void> openFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      print('Error opening file: $e');
    }
  }
}