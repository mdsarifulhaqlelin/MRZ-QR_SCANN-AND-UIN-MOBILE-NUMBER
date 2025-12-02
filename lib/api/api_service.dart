// lib/api/api_service.dart (UPDATED)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mv/models/certificate_model.dart';

// --- API Constants ---
const String BASE_URL = "https://api.mrzaivs.com";
const String VALIDATE_ENDPOINT = "/web/validate";
const String VERIFY_RESULT_ENDPOINT = "/web/verify-result";

class ApiService {
  // --- Method 1: For QR Code Validation ---
  Future<Map<String, dynamic>> validateWithQr({
    required String qr,
    required String mobile,
  }) async {
    final body = {'qr': qr, 'mobile': mobile};
    
    print('🔵 Sending QR Validation Request...');
    print('📤 Request Body: $body');
    print('📤 URL: $BASE_URL$VALIDATE_ENDPOINT');
    
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL$VALIDATE_ENDPOINT'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return {
            'applicationId': data['applicationId'] ?? '',
            'token': data['token'] ?? '',
            'uin': data['uin'] ?? '',
          };
        } else {
          throw Exception(data['message'] ?? 'QR Validation failed');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ QR Validation Error: $e');
      rethrow;
    }
  }

  // --- Method 2: For UIN + Mobile Validation ---
  Future<Map<String, dynamic>> validateWithUin({
    required String uin,
    required String mobile,
  }) async {
    final body = {'uin': uin, 'mobile': mobile};
    
    print('🔵 Sending UIN Validation Request...');
    print('📤 Request Body: $body');
    
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL$VALIDATE_ENDPOINT'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return {
            'applicationId': data['applicationId'] ?? '',
            'token': data['token'] ?? '',
            'uin': data['uin'] ?? uin,
          };
        } else {
          throw Exception(data['message'] ?? 'UIN Validation failed');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ UIN Validation Error: $e');
      rethrow;
    }
  }

  // --- Method 3: Fetch Verification Results ---
  Future<List<Certificate>> fetchVerificationResult({
    required String applicationId,
    required String token,
  }) async {
    final url = '$BASE_URL$VERIFY_RESULT_ENDPOINT?applicationId=$applicationId&t=$token';
    
    print('🔄 Fetching Results from: $url');
    
    try {
      final response = await http.get(Uri.parse(url));
      
      print('📥 Results Status: ${response.statusCode}');
      print('📥 Results Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (result['success'] == true && result['data'] != null) {
          final List applications = result['data']['applications'] ?? [];
          
          if (applications.isEmpty) {
            throw Exception('No certificate data found');
          }
          
          return applications.map((json) => Certificate.fromJson(json)).toList();
        } else {
          throw Exception(result['message'] ?? 'Failed to fetch results');
        }
      } else {
        throw Exception('HTTP Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error fetching results: $e');
      rethrow;
    }
  }

  // --- Method 4: Get PDF Download URL ---
  String getPdfDownloadUrl(String fileUrl) {
    if (fileUrl.startsWith('http')) {
      return fileUrl;
    }
    return '$BASE_URL$fileUrl';
  }
}