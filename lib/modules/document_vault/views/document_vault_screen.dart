import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/document_controller.dart';
import '../models/document_model.dart';
import 'document_preview_screen.dart';

// --------------------------------------------------
// DOCUMENT VAULT SCREEN
// --------------------------------------------------

class DocumentVaultScreen extends StatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  State<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

// --------------------------------------------------
// RENAME DIALOG
// --------------------------------------------------

class RenameDocumentDialog extends StatefulWidget {
  final String initialName;
  final String extension;

  const RenameDocumentDialog({
    super.key,
    required this.initialName,
    required this.extension,
  });

  @override
  State<RenameDocumentDialog> createState() => _RenameDocumentDialogState();
}

class _RenameDocumentDialogState extends State<RenameDocumentDialog> {
  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Rename Document',
        style: TextStyle(color: Color(0xFF251442), fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: nameController,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Document name',
          suffixText: widget.extension,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7),
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, nameController.text);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// DOCUMENT VAULT STATE
// --------------------------------------------------

class _DocumentVaultScreenState extends State<DocumentVaultScreen> {
  static const Color primaryColor = Color(0xFF673AB7);
  static const Color backgroundColor = Color(0xFFF8F7FC);
  static const Color headingColor = Color(0xFF251442);

  final DocumentController controller = Get.put(DocumentController());

  final TextEditingController searchController = TextEditingController();

  final List<String> categories = [
    'All',
    'Notes',
    'Certificates',
    'Personal',
    'Others',
  ];

  String selectedCategory = 'All';
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Filter documents by category and search.
  List<DocumentModel> getFilteredDocuments(List<DocumentModel> documents) {
    return documents.where((document) {
      final matchesCategory =
          selectedCategory == 'All' || document.category == selectedCategory;

      final matchesSearch = document.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      return matchesCategory && matchesSearch;
    }).toList();
  }

  // Choose a document category.
  Future<void> showCategoryPicker() async {
    final category = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Category',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 15),
              ...categories.skip(1).map((category) {
                return ListTile(
                  leading: const Icon(
                    Icons.folder_rounded,
                    color: primaryColor,
                  ),
                  title: Text(category),
                  onTap: () {
                    Navigator.pop(context, category);
                  },
                );
              }),
            ],
          ),
        );
      },
    );

    if (category != null) {
      await controller.addDocument(category);
    }
  }

  // Format file size.
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Get file icon.
  IconData getFileIcon(String fileType) {
    if (fileType.toLowerCase() == 'pdf') {
      return Icons.picture_as_pdf_rounded;
    }

    return Icons.image_rounded;
  }

  // Open document preview.
  void openDocument(DocumentModel document) {
    Get.to(() => DocumentPreviewScreen(document: document));
  }

  // Show rename dialog.
  Future<void> showRenameDialog(DocumentModel document) async {
    final extensionIndex = document.name.lastIndexOf('.');

    final currentName = extensionIndex > 0
        ? document.name.substring(0, extensionIndex)
        : document.name;

    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return RenameDocumentDialog(
          initialName: currentName,
          extension: extensionIndex > 0
              ? document.name.substring(extensionIndex)
              : '',
        );
      },
    );

    if (!mounted || newName == null) return;

    await controller.renameDocument(document, newName);
  }

  // Confirm document deletion.
  Future<void> confirmDelete(DocumentModel document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Delete Document?',
            style: TextStyle(color: headingColor, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${document.name}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    await controller.deleteDocument(document);
  }

  // Document options menu.
  Widget documentOptionsMenu(DocumentModel document) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
      color: Colors.white,
      onSelected: (value) {
        if (value == 'rename') {
          showRenameDialog(document);
        } else if (value == 'delete') {
          confirmDelete(document);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'rename',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: primaryColor, size: 20),
              SizedBox(width: 10),
              Text('Rename'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 10),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Document Vault',
          style: TextStyle(color: headingColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: headingColor),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Documents',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: headingColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Keep your important documents organised in one place.',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),

                    // Search field.
                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search documents...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: primaryColor,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: headingColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category filters.
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((category) {
                          final isSelected = selectedCategory == category;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              selectedColor: primaryColor,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : headingColor,
                                fontWeight: FontWeight.w500,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  selectedCategory = category;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Document list.
                    Obx(() {
                      final filteredDocuments = getFilteredDocuments(
                        controller.documents.toList(),
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'My Files',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: headingColor,
                                ),
                              ),
                              Text(
                                '${filteredDocuments.length} Documents',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          if (controller.isLoading.value &&
                              controller.documents.isEmpty)
                            const Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                              ),
                            )
                          else if (filteredDocuments.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 30,
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(25),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(
                                          alpha: 0.08,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.folder_open_rounded,
                                        size: 65,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      searchQuery.isNotEmpty ||
                                              selectedCategory != 'All'
                                          ? 'No Matching Documents'
                                          : 'No Documents Yet',
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: headingColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Your documents will appear here.\n'
                                      'Start by adding your first file.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...filteredDocuments.map((document) {
                              return Card(
                                color: Colors.white,
                                elevation: 0,
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: ListTile(
                                  onTap: () {
                                    openDocument(document);
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 7,
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(11),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      getFileIcon(document.fileType),
                                      color: primaryColor,
                                      size: 25,
                                    ),
                                  ),
                                  title: Text(
                                    document.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: headingColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${document.category} • '
                                    '${formatFileSize(document.fileSize)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  trailing: documentOptionsMenu(document),
                                ),
                              );
                            }),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Add document button.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : showCategoryPicker,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add Documents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryColor.withValues(
                        alpha: 0.5,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
