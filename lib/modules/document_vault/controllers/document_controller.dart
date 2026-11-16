import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;

import '../models/document_model.dart';
import '../services/document_file_service.dart';
import '../services/document_storage_service.dart';

class DocumentController extends GetxController {
  final DocumentFileService _fileService = DocumentFileService();
  final DocumentStorageService _storageService = DocumentStorageService();

  final RxList<DocumentModel> documents = <DocumentModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
  }

  // Load saved documents.
  Future<void> loadDocuments() async {
    try {
      isLoading.value = true;

      final result = await _storageService.getDocuments();
      documents.assignAll(result);
    } catch (e) {
      debugPrint('DOCUMENT LOAD ERROR: $e');
      Get.snackbar('Error', 'Could not load documents.');
    } finally {
      isLoading.value = false;
    }
  }

  // Import a document.
  Future<void> addDocument(String category) async {
    File? savedFile;

    try {
      final selectedFile = await _fileService.pickDocument();

      if (selectedFile == null) return;

      isLoading.value = true;

      savedFile = await _fileService.saveDocument(selectedFile);

      final extension = path
          .extension(selectedFile.path)
          .replaceFirst('.', '')
          .toLowerCase();

      final fileSize = await _fileService.getFileSize(savedFile.path);

      final document = DocumentModel(
        name: path.basename(selectedFile.path),
        filePath: savedFile.path,
        fileType: extension,
        category: category,
        fileSize: fileSize,
        createdAt: DateTime.now(),
      );

      await _storageService.insertDocument(document);
      await loadDocuments();

      Get.snackbar(
        'Success',
        'Document added successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stackTrace) {
      debugPrint('DOCUMENT IMPORT ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (savedFile != null) {
        await _fileService.deleteDocumentFile(savedFile.path);
      }

      Get.snackbar(
        'Import Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Rename a document.
  Future<void> renameDocument(DocumentModel document, String newName) async {
    final trimmedName = newName.trim();

    if (trimmedName.isEmpty) {
      Get.snackbar('Invalid Name', 'Document name cannot be empty.');
      return;
    }

    // Preserve the original file extension.
    final extension = path.extension(document.name);
    final nameWithoutExtension = path.basenameWithoutExtension(trimmedName);

    if (nameWithoutExtension.isEmpty) {
      Get.snackbar('Invalid Name', 'Enter a valid document name.');
      return;
    }

    final updatedName = '$nameWithoutExtension$extension';

    try {
      final updatedDocument = DocumentModel(
        id: document.id,
        name: updatedName,
        filePath: document.filePath,
        fileType: document.fileType,
        category: document.category,
        fileSize: document.fileSize,
        createdAt: document.createdAt,
      );

      await _storageService.updateDocument(updatedDocument);
      await loadDocuments();

      Get.snackbar(
        'Success',
        'Document renamed successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('DOCUMENT RENAME ERROR: $e');

      Get.snackbar('Error', 'Could not rename document.');
    }
  }

  // Delete a document and its actual file.
  Future<void> deleteDocument(DocumentModel document) async {
    try {
      if (document.id == null) {
        throw Exception('Invalid document ID.');
      }

      await _fileService.deleteDocumentFile(document.filePath);

      await _storageService.deleteDocument(document.id!);

      await loadDocuments();

      Get.snackbar(
        'Deleted',
        'Document deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('DOCUMENT DELETE ERROR: $e');

      Get.snackbar('Error', 'Could not delete document.');
    }
  }
}
