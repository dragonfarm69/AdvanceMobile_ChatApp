import 'package:ai_chat_app/Classes/knowledge.dart';
import 'package:ai_chat_app/features/services/knowledge_management.dart';
import 'package:flutter/material.dart';
import '../../features/services/bot_management.dart';
import '../../Classes/bot.dart';
import '../../Components/editableField.dart';
import '../../Classes/knowledgeResponse.dart';
import '../Ask Screen/askBot.dart';

class BotDetailView extends StatefulWidget {
  final Bot bot;
  final VoidCallback onBack;
  final Function(Bot) onDelete;
  final VoidCallback onUpdate;

  const BotDetailView({
    Key? key,
    required this.bot,
    required this.onBack,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _BotDetailViewState createState() => _BotDetailViewState();
}

class _BotDetailViewState extends State<BotDetailView> {
  final BotManagement _botService = BotManagement();
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController instructionsController;
  bool _isUpdating = false; // Add this flag

  final KnowledgeManager _knowledgeManager = KnowledgeManager();

  List<KnowledgeResponse>? _botKnowledges;
  List<KnowledgeBase>? _availableKnowledges;
  bool _isLoadingBotKnowledge = false;
  bool _isLoadingAvailableKnowledge = false;
  String? _knowledgeError;
  String? _availableKnowledgeError;

  Future<void> _fetchBotKnowledge() async {
    setState(() {
      _isLoadingBotKnowledge = true;
      _knowledgeError = null;
    });

    try {
      final knowledges = await _botService.getKnowledge(widget.bot!.id!);
      setState(() {
        _botKnowledges = knowledges;
        _isLoadingBotKnowledge = false;
      });
    } catch (e) {
      setState(() {
        _knowledgeError = e.toString();
        _isLoadingBotKnowledge = false;
      });
    }
  }

  Future<void> _fetchAvailableKnowledge() async {
    setState(() {
      _isLoadingAvailableKnowledge = true;
      _availableKnowledgeError = null;
    });

    try {
      final knowledges = await _knowledgeManager.getKnowledges();

      //remove kowledge that is already in the bot
      if (_botKnowledges != null) {
        knowledges.removeWhere((knowledge) {
          return _botKnowledges!.any(
            (botKnowledge) => botKnowledge.data[0].id == knowledge.id,
          );
        });
      }

      print("new available knowledges: $knowledges");

      setState(() {
        _availableKnowledges = knowledges;
        _isLoadingAvailableKnowledge = false;
      });
    } catch (e) {
      setState(() {
        _availableKnowledgeError = e.toString();
        _isLoadingAvailableKnowledge = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.bot.assistantName);
    descriptionController = TextEditingController(
      text: widget.bot.description ?? "",
    );
    instructionsController = TextEditingController(
      text: widget.bot.instructions,
    );

    _fetchBotKnowledge();
    _fetchAvailableKnowledge();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    instructionsController.dispose();
    super.dispose();
  }

  Future<void> _updateBot() async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text('Update ${widget.bot.assistantName}?'),
              content: const Text('Are you sure you want to edit this bot?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Update'),
                ),
              ],
            ),
      );

      if (confirmed == true) {
        await _botService.updateBot(
          nameController.text,
          instructionsController.text,
          descriptionController.text,
          widget.bot.id!,
        );

        widget.onUpdate();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bot updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top app bar with back button and actions
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                color: Colors.white,
                onPressed: widget.onBack,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.bot.assistantName ?? 'Bot Details',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: Colors.redAccent,
                tooltip: 'Delete Bot',
                onPressed: () => widget.onDelete(widget.bot),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Chat with bot action button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text("Bot Preview", style: TextStyle(fontSize: 20)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C6BC0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AskScreen(
                        botId: widget.bot.id!,
                        apiBaseUrl: 'https://knowledge-api.dev.jarvis.cx',
                        botName: widget.bot.assistantName,
                      ),
                ),
              );
            },
          ),
        ),

        // Bot details section
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Editable section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bot Configuration",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildEditableField("Name", nameController),
                        buildEditableField(
                          "Description",
                          descriptionController,
                          maxLines: 3,
                        ),
                        buildEditableField(
                          "Instructions",
                          instructionsController,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        _buildKnowledgeBaseUpload(context),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Metadata section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Bot Metadata",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          "Created At",
                          widget.bot.createdAt.toString(),
                        ),
                        _buildDetailItem(
                          "Updated At",
                          widget.bot.updatedAt.toString(),
                        ),
                        _buildDetailItem(
                          "Created By",
                          widget.bot.createdBy ?? "Unknown",
                        ),
                        _buildDetailItem(
                          "Updated By",
                          widget.bot.updatedBy ?? "Unknown",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Save button
                  Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_outlined),
                      label: const Text("SAVE CHANGES"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C6BC0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 3,
                      ),
                      onPressed: () => _updateBot(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),

        // Content continues as in the original file...
        // ...
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Divider(color: Colors.grey[800]),
        ],
      ),
    );
  }

  Widget _buildKnowledgeBaseUpload(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Knowledge Base",
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.library_books),
            label: const Text("Manage Knowledge Base"),
            style: ElevatedButton.styleFrom(
              //take entire width
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _manageKnowledgeBase(context),
          ),
        ],
      ),
    );
  }

  void _manageKnowledgeBase(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder:
                (_, controller) => Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF121212),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Handle bar for dragging
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                      // Modal header with close button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Knowledge Base Management',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),

                      Divider(color: Colors.grey[800]),

                      // Knowledge base content
                      Expanded(
                        child: ListView(
                          controller: controller,
                          padding: const EdgeInsets.all(16),
                          children: [
                            // Current knowledge section
                            Text(
                              "Current Knowledge",
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildBotKnowledgeSection(),

                            const SizedBox(height: 24),

                            // Add knowledge section
                            Text(
                              "Available Knowledges",
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _buildAvailableKnowledgeSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  Widget _buildBotKnowledgeSection() {
    if (_isLoadingBotKnowledge) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_knowledgeError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Error loading knowledge: $_knowledgeError",
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (_botKnowledges == null || _botKnowledges!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "No knowledge added yet",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Display knowledge items
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _botKnowledges!.length,
      itemBuilder: (context, index) {
        final knowledge = _botKnowledges![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Row(
            children: [
              const Icon(Icons.description, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      knowledge.data[0].knowledgeName ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  // Set loading state
                  setState(() {
                    _isLoadingBotKnowledge = true;
                  });

                  try {
                    // Remove knowledge
                    await _botService.removeKnowledge(
                      widget.bot.id,
                      knowledge.data[0].id,
                    );

                    // Reload data
                    await _fetchBotKnowledge();
                    await _fetchAvailableKnowledge();

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Knowledge removed successfully'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    // Show error and reset loading state
                    setState(() {
                      _isLoadingBotKnowledge = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to remove knowledge: ${e.toString()}',
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvailableKnowledgeSection() {
    if (_isLoadingAvailableKnowledge) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_availableKnowledgeError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          "Error loading knowledge bases: $_availableKnowledgeError",
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }

    if (_availableKnowledges == null || _availableKnowledges!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "No knowledge bases available",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Display knowledge items
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _availableKnowledges!.length,
      itemBuilder: (context, index) {
        final knowledge = _availableKnowledges![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Row(
            children: [
              const Icon(Icons.description, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      knowledge.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      knowledge.description,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Units: ${knowledge.numUnits}",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Size: ${knowledge.totalSize}",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF5C6BC0),
                ),
                onPressed: () async {
                  setState(() {
                    _isLoadingAvailableKnowledge = true;
                  });

                  await _botService.addKnowledge(widget.bot.id!, knowledge.id);
                  // // Reload data
                  await _fetchBotKnowledge();
                  await _fetchAvailableKnowledge();
                },
                tooltip: "Add to bot",
              ),
            ],
          ),
        );
      },
    );
  }
}
