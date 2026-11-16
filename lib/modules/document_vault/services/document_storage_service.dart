import 'package:get_storage/get_storage.dart';

import '../models/document_model.dart';

class DocumentStorageService {
  final GetStorage _storage = GetStorage();

  static const String _documentsKey = 'vault_documents';

  // Save document metadata.
  Future<int> insertDocument(DocumentModel document) async {
    final documents = await getDocuments();

    final newId = documents.isEmpty
        ? 1
        : documents.map((doc) => doc.id ?? 0).reduce((a, b) => a > b ? a : b) +
              1;

    final newDocument = DocumentModel(
      id: newId,
      name: document.name,
      filePath: document.filePath,
      fileType: document.fileType,
      category: document.category,
      fileSize: document.fileSize,
      createdAt: document.createdAt,
    );

    documents.insert(0, newDocument);

    await _storage.write(
      _documentsKey,
      documents.map((doc) => doc.toMap()).toList(),
    );

    return newId;
  }

  // Retrieve all saved documents.
  Future<List<DocumentModel>> getDocuments() async {
    final data = _storage.read<List>(_documentsKey);

    if (data == null) return [];

    return data
        .map(
          (item) =>
              DocumentModel.fromMap(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  // Update document metadata.
  Future<int> updateDocument(DocumentModel document) async {
    final documents = await getDocuments();

    final index = documents.indexWhere((item) => item.id == document.id);

    if (index == -1) return 0;

    documents[index] = document;

    await _storage.write(
      _documentsKey,
      documents.map((doc) => doc.toMap()).toList(),
    );

    return 1;
  }

  // Delete document metadata.
  Future<int> deleteDocument(int id) async {
    final documents = await getDocuments();

    final initialLength = documents.length;

    documents.removeWhere((document) => document.id == id);

    if (documents.length == initialLength) return 0;

    await _storage.write(
      _documentsKey,
      documents.map((doc) => doc.toMap()).toList(),
    );

    return 1;
  }
}
