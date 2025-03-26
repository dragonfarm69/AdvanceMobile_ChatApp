import 'package:flutter/material.dart';

class KnowledgeSourceDialog extends StatelessWidget {
  const KnowledgeSourceDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen size for constraints
    final screenSize = MediaQuery.of(context).size;
    final maxHeight = screenSize.height * 0.7; // 70% of screen height
    final maxWidth = screenSize.width * 0.85; // 85% of screen width

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: const Color(0xFF1E1E1E), // Dark background
      // Add constraints to prevent overflow
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Select Knowledge Source',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.blue.shade300, // Lighter blue for dark mode
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Text(
                'Choose where to import your knowledge from:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70, // Light gray text for dark mode
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),

              // Add scroll view for vertical overflow
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Knowledge source options
                      _buildSourceCard(
                        context,
                        icon: Icons.file_present,
                        title: 'Local Files',
                        subtitle: 'Upload PDF, DOCX, TXT and other documents',
                        color: Colors.blue,
                        onTap: () => Navigator.of(context).pop('local_files'),
                      ),

                      const SizedBox(height: 12),
                      _buildSourceCard(
                        context,
                        icon: Icons.language,
                        title: 'Website',
                        subtitle: 'Connect to websites to extract knowledge',
                        color: Colors.green,
                        onTap: () => Navigator.of(context).pop('website'),
                      ),

                      const SizedBox(height: 12),
                      _buildSourceCard(
                        context,
                        icon: Icons.drive_file_move_outlined,
                        title: 'Google Drive',
                        subtitle: 'Import documents from your Drive account',
                        color: Colors.amber,
                        comingSoon: true,
                        onTap: () {}, // Coming soon
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool comingSoon = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: comingSoon ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:
                comingSoon
                    ? const Color(
                      0xFF2A2A2A,
                    ) // Darker gray for coming soon in dark mode
                    : Color.alphaBlend(
                      color.withOpacity(0.15),
                      const Color(0xFF2D2D2D),
                    ),
            border: Border.all(
              color: comingSoon ? Colors.grey.shade700 : color.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        comingSoon
                            ? Colors.grey.shade800
                            : color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color:
                        comingSoon
                            ? Colors.grey.shade500
                            : color.withOpacity(0.9),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color:
                              comingSoon ? Colors.grey.shade500 : Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              comingSoon
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade400,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (comingSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: color.withOpacity(0.7),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
