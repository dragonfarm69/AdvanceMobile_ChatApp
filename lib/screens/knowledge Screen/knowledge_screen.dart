import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../Classes/knowledge.dart';
import '../../Classes/knowledgeUnit.dart';
import '../../features/services/knowledge_management.dart';
import 'knowledge_detail_screen.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({Key? key}) : super(key: key);

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final KnowledgeManager _knowledgeManager = KnowledgeManager();
  List<KnowledgeBase> knowledgeBases = [];
  Map<String, List<KnowledgeUnit>> knowledgeUnits = {};
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadKnowledgeBases();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadKnowledgeBases() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final loadedKnowledges = await _knowledgeManager.getKnowledges();

      setState(() {
        knowledgeBases = loadedKnowledges;
        for (var kb in knowledgeBases) {
          knowledgeUnits[kb.id] = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load knowledge bases: ${e.toString()}";
      });
    }
  }

  void _addNewKnowledgeBase() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create New Knowledge Base"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  hintText: "Enter knowledge base name",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "Enter knowledge base description",
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    Navigator.pop(context);
                    // Show loading indicator
                    setState(() {
                      _isLoading = true;
                    });

                    // Call API to create knowledge base
                    await _knowledgeManager.createKnowledge(
                      nameController.text,
                      descriptionController.text,
                    );

                    // Reload the list to get the new knowledge base
                    await _loadKnowledgeBases();
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage =
                          "Failed to create knowledge base: ${e.toString()}";
                    });
                  }
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }

  void _editKnowledgeBase(KnowledgeBase kb) {
    final nameController = TextEditingController(text: kb.name);
    final descriptionController = TextEditingController(text: kb.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Knowledge Base"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    Navigator.pop(context);
                    // Show loading indicator
                    setState(() {
                      _isLoading = true;
                    });

                    // Call API to update knowledge base
                    await _knowledgeManager.updateKnowledge(
                      kb.id,
                      nameController.text,
                      descriptionController.text,
                    );

                    // Reload the list to get the updated knowledge base
                    await _loadKnowledgeBases();
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage =
                          "Failed to update knowledge base: ${e.toString()}";
                    });
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteKnowledgeBase(KnowledgeBase kb) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: Text("Are you sure you want to delete '${kb.name}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  Navigator.pop(context);
                  // Show loading indicator
                  setState(() {
                    _isLoading = true;
                  });

                  // Call API to delete knowledge base
                  await _knowledgeManager.deleteKnowledge(kb.id);

                  // Reload the list
                  await _loadKnowledgeBases();
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage =
                        "Failed to delete knowledge base: ${e.toString()}";
                  });
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndAddKnowledgeUnit(String knowledgeId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = path.basename(file.path);
      String fileExtension = path.extension(file.path).replaceFirst('.', '');
      int fileSize = await file.length();

      setState(() {
        final newUnit = KnowledgeUnit(
          id: "ku${DateTime.now().millisecondsSinceEpoch}",
          name: fileName,
          type: fileExtension,
          size: fileSize,
          status: true,
          knowledgeId: knowledgeId,
          metadata: Metadata(
            fileId: "f${DateTime.now().millisecondsSinceEpoch}",
            fileUrl: file.path,
            mimeType: _getMimeType(fileExtension),
          ),
        );

        if (knowledgeUnits.containsKey(knowledgeId)) {
          knowledgeUnits[knowledgeId]!.add(newUnit);
        } else {
          knowledgeUnits[knowledgeId] = [newUnit];
        }

        // Update the knowledge base stats
        final index = knowledgeBases.indexWhere((kb) => kb.id == knowledgeId);
        if (index != -1) {
          final units = knowledgeUnits[knowledgeId]!.length.toString();
          final totalSize = _calculateTotalSize(knowledgeUnits[knowledgeId]!);
          knowledgeBases[index] = KnowledgeBase(
            name: knowledgeBases[index].name,
            description: knowledgeBases[index].description,
            id: knowledgeId,
            numUnits: units,
            totalSize: totalSize,
          );
        }
      });
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  String _calculateTotalSize(List<KnowledgeUnit> units) {
    double totalBytes = 0;
    for (var unit in units) {
      totalBytes += unit.size?.toDouble() ?? 0;
    }

    if (totalBytes < 1024) {
      return "${totalBytes.toStringAsFixed(2)}B";
    } else if (totalBytes < 1024 * 1024) {
      return "${(totalBytes / 1024).toStringAsFixed(2)}KB";
    } else if (totalBytes < 1024 * 1024 * 1024) {
      return "${(totalBytes / (1024 * 1024)).toStringAsFixed(2)}MB";
    } else {
      return "${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB";
    }
  }

  Widget _buildKnowledgeCard(KnowledgeBase kb) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => KnowledgeDetailScreen(
                    numberOfUnits: kb.numUnits,
                    knowledgeBase: kb,
                    units: knowledgeUnits[kb.id] ?? [],
                    onAddUnit: () => _pickAndAddKnowledgeUnit(kb.id),
                    onUnitStatusChanged: (unit, status) {
                      setState(() {
                        final units = knowledgeUnits[kb.id]!;
                        final index = units.indexWhere((u) => u.id == unit.id);
                        if (index != -1) {
                          units[index] = KnowledgeUnit(
                            id: unit.id,
                            name: unit.name,
                            type: unit.type,
                            size: unit.size,
                            status: status,
                            knowledgeId: unit.knowledgeId,
                            metadata: unit.metadata,
                          );
                        }
                      });
                    },
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withOpacity(0.2),
                    child: Icon(
                      Icons.book,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kb.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kb.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editKnowledgeBase(kb);
                      } else if (value == 'delete') {
                        _deleteKnowledgeBase(kb);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Chip(
                    avatar: const Icon(Icons.library_books, size: 16),
                    label: Text("Units: ${kb.numUnits}"),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    avatar: const Icon(Icons.storage, size: 16),
                    label: Text("Size: ${kb.totalSize}"),
                    backgroundColor: Colors.green.withOpacity(0.1),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            "No knowledge bases found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the '+' button to create your first knowledge base",
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addNewKnowledgeBase,
            icon: const Icon(Icons.add),
            label: const Text("Create Knowledge Base"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? "An error occurred",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.red[700]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadKnowledgeBases,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  List<KnowledgeBase> get _filteredKnowledgeBases {
    if (_searchQuery.isEmpty) {
      return knowledgeBases;
    }
    return knowledgeBases
        .where(
          (kb) =>
              kb.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              kb.description.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Knowledge Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadKnowledgeBases,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              controller: _searchController,
              decoration: InputDecoration(
                hintStyle: const TextStyle(
                  color: Color.fromARGB(255, 134, 132, 132),
                ),
                hintText: 'Search knowledge bases...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Loading knowledge bases...',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : _errorMessage != null
                    ? _buildErrorState()
                    : knowledgeBases.isEmpty
                    ? _buildEmptyState()
                    : _filteredKnowledgeBases.isEmpty
                    ? Center(
                      child: Text(
                        'No results matching "${_searchController.text}"',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadKnowledgeBases,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: _filteredKnowledgeBases.length,
                        itemBuilder: (context, index) {
                          return _buildKnowledgeCard(
                            _filteredKnowledgeBases[index],
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewKnowledgeBase,
        icon: const Icon(Icons.add),
        label: const Text("New Knowledge Base"),
      ),
    );
  }
}
