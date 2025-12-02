// lib/models/certificate_model.dart

class Certificate {
  final String id;
  final String title;
  final String userName;
  final String uin;
  final String mobile;
  final String status;
  final String details;
  final String fileUrl;
  final String createdAt;

  Certificate({
    required this.id,
    required this.title,
    required this.userName,
    required this.uin,
    required this.mobile,
    required this.status,
    required this.details,
    required this.fileUrl,
    required this.createdAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'N/A',
      userName: json['userName']?.toString() ?? 'N/A',
      uin: json['uin']?.toString() ?? 'N/A',
      mobile: json['mobile']?.toString() ?? 'N/A',
      status: json['status']?.toString() ?? 'N/A',
      details: json['details']?.toString() ?? 'N/A',
      fileUrl: json['fileUrl']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  // Helper method to format date
  String get formattedDate {
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdAt;
    }
  }

  // Check if certificate is approved
  bool get isApproved => status.toLowerCase() == 'approved';
}