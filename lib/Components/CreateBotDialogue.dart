import 'package:flutter/material.dart';
import 'KnowledgeSourceDialogue.dart';

class CreateBotDialog extends StatefulWidget {
  const CreateBotDialog({Key? key}) : super(key: key);

  @override
  _CreateBotDialogState createState() => _CreateBotDialogState();
}

class _CreateBotDialogState extends State<CreateBotDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  bool _advancedOptionsExpanded = false;
  final _formKey = GlobalKey<FormState>();
  List<String> _knowledgeSources = [];

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive constraints
    final Size screenSize = MediaQuery.of(context).size;
    final double dialogWidth = screenSize.width > 600 ? 500 : screenSize.width * 0.9;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Constrain dialog width to prevent horizontal overflow
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.8,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Enhanced header
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.smart_toy_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Create Your Own Bot',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Name TextField with validation
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'E.g., "Customer Support Bot"',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.badge_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name for your bot';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Instructions TextField
                  TextFormField(
                    controller: _instructionsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Instructions',
                      hintText: 'Describe how your bot should behave and respond',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 50.0),
                        child: Icon(Icons.description_outlined),
                      ),
                      helperText: 'Optional: Add guidelines or specific rules if needed',
                      helperMaxLines: 2,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Knowledge Base Section with improved styling
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.psychology_outlined),
                          title: const Text('Knowledge Base'),
                          subtitle: const Text(
                            'Add sources to enhance your bot\'s intelligence',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Colors.blue,
                            ),
                            onPressed: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => const KnowledgeSourceDialog(),
                              );
                              
                              if (result != null && mounted) {
                                setState(() {
                                  _knowledgeSources.add(result.toString());
                                });
                              }
                            },
                          ),
                        ),
                        
                        // Display added knowledge sources
                        if (_knowledgeSources.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              bottom: 16.0,
                            ),
                            child: Wrap(
                              spacing: 8.0,
                              children: _knowledgeSources.map((source) {
                                return Chip(
                                  label: Text(
                                    source,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  deleteIcon: const Icon(Icons.close, size: 16),
                                  onDeleted: () {
                                    setState(() {
                                      _knowledgeSources.remove(source);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Improved Advanced Options Expansion
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: ExpansionTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Advanced Options'),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _advancedOptionsExpanded = expanded;
                        });
                      },
                      initiallyExpanded: _advancedOptionsExpanded,
                      childrenPadding: const EdgeInsets.all(16),
                      children: [
                        // Advanced options content
                        ListTile(
                          title: const Text('Model Selection'),
                          subtitle: const Text('Choose AI model capabilities'),
                          trailing: DropdownButton<String>(
                            value: 'Standard',
                            items: ['Standard', 'Advanced', 'Expert']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (_) {},
                          ),
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Memory Retention'),
                          subtitle: const Text('Remember conversation history'),
                          value: true,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons with improved styling
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Cancel'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop({
                              'name': _nameController.text,
                              'instructions': _instructionsController.text,
                              'knowledgeSources': _knowledgeSources,
                            });
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Create Bot'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}