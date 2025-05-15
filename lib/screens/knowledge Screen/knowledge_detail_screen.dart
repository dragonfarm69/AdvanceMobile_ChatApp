import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../Classes/knowledge.dart';
import '../../Classes/knowledgeUnit.dart';
import '../../features/services/knowledgeUnit_management.dart';
import '../../Classes/FileResponse.dart';

class KnowledgeDetailScreen extends StatefulWidget {
  final KnowledgeBase knowledgeBase;
  final List<KnowledgeUnit> units;
  final VoidCallback onAddUnit;
  final Function(KnowledgeUnit, bool) onUnitStatusChanged;
  final String numberOfUnits;

  const KnowledgeDetailScreen({
    Key? key,
    required this.knowledgeBase,
    required this.units,
    required this.onAddUnit,
    required this.onUnitStatusChanged,
    required this.numberOfUnits,
  }) : super(key: key);

  @override
  State<KnowledgeDetailScreen> createState() => _KnowledgeDetailScreenState();
}

class _KnowledgeDetailScreenState extends State<KnowledgeDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name'; // Options: name, size, type
  bool _sortAscending = true;
  FileResponse? _lastUploadedFile;
  bool _isUploading = false;
  final KnowledgeUnitManager _knowledgeUnitManager = KnowledgeUnitManager();
  bool _showUploadedFile = false;
  bool _isLoadingUnits = false;
  String? _loadError;
  List<KnowledgeUnit> _localUnits = [];
  String? _togglingUnitId;

  @override
  void initState() {
    super.initState();
    _localUnits = List.from(widget.units);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _refreshKnowledgeUnits();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshKnowledgeUnits() async {
    if (widget.knowledgeBase.id == null) {
      setState(() {
        _loadError = 'Knowledge base ID is missing';
      });
      return;
    }

    try {
      setState(() {
        _isLoadingUnits = true;
        _loadError = null;
      });

      final units = await _knowledgeUnitManager.getKnowledgeUnit(
        widget.knowledgeBase.id!,
      );

      setState(() {
        _localUnits = units;
        _isLoadingUnits = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUnits = false;
        _loadError = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load units: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _refreshKnowledgeUnits,
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  List<KnowledgeUnit> get _filteredAndSortedUnits {
    List<KnowledgeUnit> filtered = _localUnits;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (unit) =>
                    unit.name?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false,
              )
              .toList();
    }

    // Sort by selected criteria
    filtered.sort((a, b) {
      if (_sortBy == 'name') {
        return _sortAscending
            ? (a.name ?? '').compareTo(b.name ?? '')
            : (b.name ?? '').compareTo(a.name ?? '');
      } else if (_sortBy == 'size') {
        return _sortAscending
            ? (a.size ?? 0).compareTo(b.size ?? 0)
            : (b.size ?? 0).compareTo(a.size ?? 0);
      } else if (_sortBy == 'type') {
        return _sortAscending
            ? (a.type ?? '').compareTo(b.type ?? '')
            : (b.type ?? '').compareTo(a.type ?? '');
      }
      return 0;
    });

    return filtered;
  }

  String _calculateTotalSize() {
    int totalBytes = 0;
    for (var unit in _localUnits) {
      totalBytes += unit.size ?? 0;
    }
    return _formatFileSize(totalBytes);
  }

  @override
  Widget build(BuildContext context) {
    final totalSize = _calculateTotalSize();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.knowledgeBase.name),
        actions: [
          IconButton(
            icon:
                _isLoadingUnits
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(Icons.refresh),
            onPressed: _isLoadingUnits ? null : _refreshKnowledgeUnits,
            tooltip: 'Refresh units',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Knowledge Base Header with stats
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
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
                        Icons.folder_open,
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
                            widget.knowledgeBase.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.knowledgeBase.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatCard(
                      context,
                      Icons.library_books,
                      '${widget.numberOfUnits}',
                      'Units',
                      Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      Icons.storage,
                      totalSize,
                      'Total Size',
                      Colors.green,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Header for units list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Knowledge Units (${_filteredAndSortedUnits.length})",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${widget.units.length - _filteredAndSortedUnits.length} hidden",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Knowledge units list
          if (_isLoadingUnits && _localUnits.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_loadError != null && _localUnits.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: $_loadError',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child:
                _filteredAndSortedUnits.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      itemCount: _filteredAndSortedUnits.length,
                      padding: const EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) {
                        final unit = _filteredAndSortedUnits[index];
                        return _buildKnowledgeUnitCard(unit, context);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: (int.tryParse(widget.numberOfUnits) ?? 0) >= 1 
          ? FloatingActionButton.extended(
          onPressed: _isUploading ? null : _handleFileUpload,
          icon:
          _isUploading
              ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
              : const Icon(Icons.add),
          label: Text(_isUploading ? "Uploading..." : "Add Unit"),
          tooltip: "Add new knowledge unit",
          backgroundColor: _isUploading ? Colors.grey : null,
        )
          : null,
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKnowledgeUnitCard(KnowledgeUnit unit, BuildContext context) {
    final isToggling = _togglingUnitId == unit.id;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: SizedBox(
            width: 40,
            height: 40,
            child: _getFileIcon(unit.type ?? ''),
          ),
          title: Text(
            unit.name ?? 'Unnamed File',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      unit.type?.toUpperCase() ?? 'UNKNOWN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatFileSize(unit.size ?? 0),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview button
              IconButton(
                icon: const Icon(Icons.visibility, size: 20),
                onPressed: () {
                  // Implement preview functionality here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Preview for ${unit.name}")),
                  );
                },
                tooltip: "Preview",
              ),
              // Status switch
              Tooltip(
                message: (unit.status ?? false) ? "Active" : "Inactive",
                child:
                    isToggling
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Switch(
                          value: unit.status ?? false,
                          onChanged: (value) async {
                            // Only proceed if we're not already toggling this or another unit
                            if (_togglingUnitId != null) return;

                            try {
                              // Set toggling state
                              setState(() {
                                _togglingUnitId = unit.id;
                              });

                              // Call the API to toggle the unit status
                              if (unit.id != null &&
                                  widget.knowledgeBase.id != null) {
                                print(value);
                                await _knowledgeUnitManager.toggleUnit(
                                  widget.knowledgeBase.id!,
                                  unit.id!,
                                  value,
                                );

                                // Update parent state
                                widget.onUnitStatusChanged(unit, value);

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Unit ${value ? 'activated' : 'deactivated'} successfully",
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );

                                //update the button
                                setState(() {
                                  unit.status = value;
                                });

                              } else {
                                throw Exception(
                                  "Missing unit ID or knowledge base ID",
                                );
                              }
                            } catch (e) {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Failed to update unit status: ${e.toString()}",
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } finally {
                              // Clear toggling state
                              if (mounted) {
                                setState(() {
                                  _togglingUnitId = null;
                                });
                              }
                            }
                          },
                        ),
              ),
            ],
          ),
          onTap: () {
            // Show detailed info or open file
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => _buildUnitDetailsSheet(unit),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUnitDetailsSheet(KnowledgeUnit unit) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _getFileIcon(unit.type ?? ''),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  unit.name ?? 'Unnamed File',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildDetailRow('Size', _formatFileSize(unit.size ?? 0)),
          _buildDetailRow('Type', unit.type?.toUpperCase() ?? 'Unknown'),
          _buildDetailRow(
            'Status',
            (unit.status ?? false) ? 'Active' : 'Inactive',
          ),
          _buildDetailRow('Knowledge ID', unit.knowledgeId),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: const Text('Preview'),
                onPressed: () {
                  Navigator.pop(context);
                  // Add preview functionality
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                onPressed: () {
                  Navigator.pop(context);
                  // Add download functionality
                },
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withOpacity(0.1),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  // Add delete functionality
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort by',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSortOption('Name', 'name'),
                _buildSortOption('File type', 'type'),
                _buildSortOption('Size', 'size'),
                const Divider(),
                _buildSortDirectionOption(),
              ],
            ),
          ),
    );
  }

  Widget _buildSortOption(String label, String sortKey) {
    return ListTile(
      title: Text(label),
      leading: Radio<String>(
        value: sortKey,
        groupValue: _sortBy,
        onChanged: (value) {
          setState(() {
            _sortBy = value!;
          });
          Navigator.pop(context);
        },
      ),
      onTap: () {
        setState(() {
          _sortBy = sortKey;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSortDirectionOption() {
    return ListTile(
      title: Text(_sortAscending ? 'Ascending order' : 'Descending order'),
      leading: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
      trailing: Switch(
        value: _sortAscending,
        onChanged: (value) {
          setState(() {
            _sortAscending = value;
          });
        },
      ),
      onTap: () {
        setState(() {
          _sortAscending = !_sortAscending;
        });
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? "No knowledge units found"
                : "No matching units found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? "Add your first unit to get started"
                : "Try a different search term",
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty)
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _handleFileUpload,
              icon:
                  _isUploading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.add),
              label: Text(_isUploading ? "Uploading..." : "Add Unit"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getFileIcon(String type) {
    IconData iconData;
    Color iconColor;

    switch (type.toLowerCase()) {
      case 'pdf':
        iconData = Icons.picture_as_pdf;
        iconColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case 'xls':
      case 'xlsx':
        iconData = Icons.table_chart;
        iconColor = Colors.green;
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
        iconData = Icons.image;
        iconColor = Colors.purple;
        break;
      case 'txt':
        iconData = Icons.text_snippet;
        iconColor = Colors.grey;
        break;
      default:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }

  String _formatFileSize(int size) {
    if (size < 1024) {
      return "${size}B";
    } else if (size < 1024 * 1024) {
      return "${(size / 1024).toStringAsFixed(2)}KB";
    } else if (size < 1024 * 1024 * 1024) {
      return "${(size / (1024 * 1024)).toStringAsFixed(2)}MB";
    } else {
      return "${(size / (1024 * 1024 * 1024)).toStringAsFixed(2)}GB";
    }
  }

  Future<void> _handleFileUpload() async {
    try {
      print("I was called");

      // First pick the file
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) {
        // User cancelled the picker
        return;
      }

      setState(() {
        _isUploading = true;
        _showUploadedFile = false; // Reset while uploading
      });

      // Call the uploadLocalFile method
      final response = await _knowledgeUnitManager.uploadLocalFile(
        result,
        widget.knowledgeBase.id!,
      );

      // Store the response
      setState(() {
        _lastUploadedFile = response;
        _isUploading = false;
        _showUploadedFile = true; // Show file details after successful upload
      });

      // Print response content
      print("Response: ${response.toJson()}");

      // Show success feedback
      if (response.files != null && response.files!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "File uploaded successfully: ${response.files![0].name}",
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Print file info to console for debugging
        print('File uploaded: ${response.files![0].name}');
        print('File ID: ${response.files![0].id}');
        print('File URL: ${response.files![0].url}');

        // ADDED: Refresh the knowledge units list after successful upload
        await _refreshKnowledgeUnits();
      }
    } catch (e) {
      // Handle errors
      setState(() {
        _isUploading = false;
        _showUploadedFile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error uploading file: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      print('Upload error: ${e.toString()}');
    }
  }

  Widget _buildUploadedFileCard() {
    if (!_showUploadedFile ||
        _lastUploadedFile?.files == null ||
        _lastUploadedFile!.files!.isEmpty) {
      return const SizedBox.shrink();
    }

    final fileInfo = _lastUploadedFile!.files![0];
    final fileType = fileInfo.extension ?? 'unknown';

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _getFileIcon(fileType),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileInfo.name ?? 'Unknown File',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploaded file',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showUploadedFile = false;
                    });
                  },
                  tooltip: 'Dismiss',
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('File ID', fileInfo.id),
            _buildDetailRow('Size', _formatFileSize(fileInfo.size ?? 0)),
            _buildDetailRow(
              'Type',
              '${fileInfo.extension?.toUpperCase() ?? 'Unknown'} (${fileInfo.mimeType ?? 'Unknown'})',
            ),
            _buildDetailRow('Created', _formatDate(fileInfo.createdAt)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.visibility),
                  label: const Text('Preview'),
                  onPressed: () {
                    // Open the preview in a web view or using url_launcher
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preview functionality coming soon'),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_task),
                  label: const Text('Add to Knowledge Base'),
                  onPressed: () {
                    // Add the file to the knowledge base
                    _addFileToKnowledgeBase(fileInfo);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  void _addFileToKnowledgeBase(FileInfo fileInfo) {
    // Here you would implement the API call to add the file to the knowledge base
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${fileInfo.name} to knowledge base'),
        backgroundColor: Colors.green,
      ),
    );

    // Hide the uploaded file card
    setState(() {
      _showUploadedFile = false;
    });
  }
}
