class DocumentModel {
  final int? id;
  final String name;
  final String filePath;
  final String fileType;
  final String category;
  final int fileSize;
  final DateTime createdAt;

  const DocumentModel({
    this.id,
    required this.name,
    required this.filePath,
    required this.fileType,
    required this.category,
    required this.fileSize,
    required this.createdAt,
  });

  // Convert document information into a Map for SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'filePath': filePath,
      'fileType': fileType,
      'category': category,
      'fileSize': fileSize,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert SQLite data back into a DocumentModel.
  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      filePath: map['filePath'] as String,
      fileType: map['fileType'] as String,
      category: map['category'] as String,
      fileSize: map['fileSize'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
