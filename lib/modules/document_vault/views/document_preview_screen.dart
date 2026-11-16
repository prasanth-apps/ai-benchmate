import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:share_plus/share_plus.dart';

import '../models/document_model.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final DocumentModel document;

  const DocumentPreviewScreen({super.key, required this.document});

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  PdfControllerPinch? _pdfController;

  bool get isPdf => widget.document.fileType.toLowerCase() == 'pdf';

  @override
  void initState() {
    super.initState();

    if (isPdf) {
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openFile(widget.document.filePath),
      );
    }
  }

  // Share document using Android's native share sheet.
  Future<void> shareDocument() async {
    try {
      final file = File(widget.document.filePath);

      if (!await file.exists()) {
        throw Exception('Document file not found.');
      }

      await SharePlus.instance.share(
        ShareParams(
          title: widget.document.name,
          text: 'Sharing ${widget.document.name}',
          files: [XFile(widget.document.filePath)],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to share document: $e')));
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.document.filePath);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: AppBar(
        title: Text(
          widget.document.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: const Color(0xFF673AB7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: shareDocument,
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share document',
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: file.exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data != true) {
            return const Center(child: Text('Document file not found.'));
          }

          if (isPdf) {
            return PdfViewPinch(controller: _pdfController!);
          }

          return Center(
            child: InteractiveViewer(
              child: Image.file(
                file,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Unable to preview this image.');
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
