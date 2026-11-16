import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class DocumentFileService {
  static const MethodChannel _channel = MethodChannel(
    'ai_benchmate/document_picker',
  );

  final Uuid _uuid = const Uuid();

  static const List<String> allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  // Pick a document using the native Android picker.
  Future<File?> pickDocument() async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'pickDocument',
    );

    if (result == null) return null;

    final selectedPath = result['path'] as String?;

    if (selectedPath == null || selectedPath.isEmpty) {
      throw Exception('Unable to access selected file.');
    }

    return File(selectedPath);
  }

  // Get private app document directory.
  Future<Directory> _getDocumentDirectory() async {
    final appDirectory = await getApplicationDocumentsDirectory();

    final documentDirectory = Directory(
      path.join(appDirectory.path, 'document_vault'),
    );

    if (!await documentDirectory.exists()) {
      await documentDirectory.create(recursive: true);
    }

    return documentDirectory;
  }

  // Copy selected file into private storage.
  Future<File> saveDocument(File sourceFile) async {
    if (!await sourceFile.exists()) {
      throw Exception('Selected file does not exist.');
    }

    final extension = path
        .extension(sourceFile.path)
        .replaceFirst('.', '')
        .toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      throw Exception('This file format is not supported.');
    }

    final directory = await _getDocumentDirectory();
    final uniqueName = '${_uuid.v4()}.$extension';

    final destinationPath = path.join(directory.path, uniqueName);

    return sourceFile.copy(destinationPath);
  }

  // Delete stored document.
  Future<void> deleteDocumentFile(String filePath) async {
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }
  }

  // Get document size.
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      throw Exception('Document file not found.');
    }

    return file.length();
  }
}
