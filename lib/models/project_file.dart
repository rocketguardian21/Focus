import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectFile {
  final String name;
  final String url;
  final String uploadedBy;
  final Timestamp uploadedAt;

  ProjectFile({
    required this.name,
    required this.url,
    required this.uploadedBy,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'uploadedBy': uploadedBy,
      'uploadedAt': uploadedAt,
    };
  }

  factory ProjectFile.create({
    required String name,
    required String url,
    required String uploadedBy,
  }) {
    return ProjectFile(
      name: name,
      url: url,
      uploadedBy: uploadedBy,
      uploadedAt: Timestamp.now(),
    );
  }
}
