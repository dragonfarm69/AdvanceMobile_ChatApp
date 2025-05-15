import 'package:flutter/material.dart';
import 'KnowledgeSourceDialogue.dart';
import '../Classes/createBotRequest.dart';

class CreateBotDialog extends StatefulWidget {
  const CreateBotDialog({Key? key}) : super(key: key);

  @override
  _CreateBotDialogState createState() => _CreateBotDialogState();
}

class _CreateBotDialogState extends State<CreateBotDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _advancedOptionsExpanded = false;
  final _formKey = GlobalKey<FormState>();
  List<String> _knowledgeSources = [];
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive constraints
    final Size screenSize = MediaQuery.of(context).size;
    final double dialogWidth =
        screenSize.width > 600 ? 500 : screenSize.width * 0.9;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;

    return Dialog(
      backgroundColor: surfaceColor,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      // Constrain dialog width to prevent horizontal overflow
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: screenSize.height * 0.8),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Enhanced header with animation
                  Center(
                    child: Column(
                      children: [
                        Hero(
                          tag: 'bot-icon',
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.smart_toy_rounded,
                              size: 48,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // Name TextField with validation and floating label
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Bot Name*',
                      hintText: 'E.g., "Customer Support Assistant"',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name for your bot';
                      }
                      if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 24),

                  // Instructions TextField with character counter
                  TextFormField(
                    controller: _instructionsController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: 'Instructions*',
                      hintText:
                          'Describe how your bot should behave, respond, and what it should know',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      helperText:
                          'Be specific about the bot\'s purpose and tone',
                      alignLabelWithHint: true,
                      helperMaxLines: 2,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please provide instructions for your bot';
                      }
                      if (value.trim().length < 20) {
                        return 'Instructions should be more detailed (min 20 chars)';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 24),

                  // Improved Advanced Options Expansion with animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ExpansionTile(
                      leading: Icon(
                        Icons.settings,
                        color:
                            _advancedOptionsExpanded
                                ? primaryColor
                                : theme.iconTheme.color,
                      ),
                      title: Text(
                        'Advanced Options',
                        style: TextStyle(
                          fontWeight:
                              _advancedOptionsExpanded
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color:
                              _advancedOptionsExpanded
                                  ? primaryColor
                                  : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      onExpansionChanged: (expanded) {
                        setState(() => _advancedOptionsExpanded = expanded);
                      },
                      initiallyExpanded: _advancedOptionsExpanded,
                      childrenPadding: const EdgeInsets.all(16),
                      backgroundColor: Colors.transparent,
                      collapsedBackgroundColor: Colors.transparent,
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: [
                        // Description field with character counter
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          maxLength: 200,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText:
                                'Short description about what this bot does',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons with improved styling
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed:
                            _isCreating
                                ? null
                                : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed:
                            _isCreating
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _isCreating = true);

                                    // Short artificial delay to show loading state
                                    Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () {
                                        final request = CreateBotRequest(
                                          name: _nameController.text.trim(),
                                          instructions:
                                              _instructionsController.text
                                                  .trim(),
                                          description:
                                              _descriptionController.text
                                                  .trim(),
                                        );
                                        Navigator.of(context).pop(request);
                                      },
                                    );
                                  }
                                },
                        icon:
                            _isCreating
                                ? Container(
                                  width: 24,
                                  height: 24,
                                  padding: const EdgeInsets.all(2.0),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                )
                                : const Icon(
                                  Icons.smart_toy,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                        label: Text(
                          _isCreating ? 'Creating...' : 'Create Bot',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(181, 0, 255, 157),
                          // foregroundColor: const Color.fromARGB(181, 255, 255, 255),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
