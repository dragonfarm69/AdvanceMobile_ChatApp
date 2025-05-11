import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  String selectedTheme = 'System (automatic)';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Slightly softer than pure black
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          controller: _scrollController,
          thickness: 6,
          radius: const Radius.circular(10),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Section headers for better organization
                  _buildSectionHeader('App Information'),
                  buildSection([
                    _buildInfoOption('About', Icons.info_outline),
                    _buildInfoOption('Privacy', Icons.privacy_tip_outlined),
                    _buildInfoOption('Terms of service', Icons.description_outlined),
                    _buildInfoOption('Usage guidelines', Icons.rule_outlined),
                    _buildInfoOption('Contact us', Icons.email_outlined),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Chat Management'),
                  buildSection([
                    ListTile(
                      leading: const Icon(Icons.delete_outline, color: Colors.pink),
                      title: const Text(
                        'Delete all chats',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _showConfirmationDialog(
                        'Delete all chats?', 
                        'This action cannot be undone.'
                      ),
                    ),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Account'),
                  buildSection([
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.pink),
                      title: const Text(
                        'Log out',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _showConfirmationDialog(
                        'Log out?', 
                        'You will need to sign in again.'
                      ),
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    ListTile(
                      leading: const Icon(Icons.devices, color: Colors.pink),
                      title: const Text(
                        'Log out of all devices',
                        style: TextStyle(
                          color: Colors.pink,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _showConfirmationDialog(
                        'Log out of all devices?', 
                        'You will be logged out from all devices.'
                      ),
                    ),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Danger Zone'),
                  buildSection([
                    ListTile(
                      leading: const Icon(Icons.no_accounts, color: Colors.red),
                      title: const Text(
                        'Delete account',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _showConfirmationDialog(
                        'Delete account?', 
                        'This action is permanent. All your data will be lost.',
                        isDestructive: true
                      ),
                    ),
                  ]),
                  
                  const SizedBox(height: 40),
                  
                  // App information footer
                  Center(
                    child: Text(
                      'Version: 4.14.0 (41414)',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'by ',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Quora',
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget buildSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 16,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
  
  Future<void> _showConfirmationDialog(
    String title, 
    String message, 
    {bool isDestructive = false}
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey.shade300),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isDestructive ? 'Delete' : 'Confirm',
              style: TextStyle(
                color: isDestructive ? Colors.red : Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}