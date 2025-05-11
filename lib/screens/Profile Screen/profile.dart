import 'package:flutter/material.dart';
import '../../Components/pressableMenuWithArrow.dart';
import '../../Components/StatefullWidgetButton.dart';
import '../../features/services/userInfo.dart';
import '../../features/model/user.dart';
import '../../features/model/subscription.dart';
import '../../features/model/tokenUsage.dart';
import '../../features/services/bot_management.dart';
import '../../features/services/knowledge_management.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Userinfo _userInfo = Userinfo();
  User? _user;
  Subscription? _subscription;
  TokenUsage? _tokenUsage;
  bool _isLoading = true;
  String? _errorMessage;
  int? _numberOfBots;
  int? _numberOfKnowledges;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userInfo.getUserInfo();
      final subscription = await _userInfo.getSubscription();
      final tokenUsage = await _userInfo.getTokenUsage();
      final numberOfBots = await BotManagement().getNumberOfBots();
      final numberOfKnowledges = await KnowledgeManager().getNumberOfKnowledges();

      // print('Number of Bots: $numberOfBots');

      if (mounted) {
        setState(() {
          _user = user;
          _subscription = subscription;
          _tokenUsage = tokenUsage;
          _numberOfBots = numberOfBots;
          _numberOfKnowledges = numberOfKnowledges;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(onPressed: _loadUserData, child: Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Profile header - Improved layout
            Container(
              color: Colors.indigo[900],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 32,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    child: Icon(
                      Icons.insert_emoticon,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user?.email.substring(
                                0,
                                _user?.email.indexOf('@'),
                              ) ??
                              'Chat App User',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _user?.email ?? 'No email available',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // const SizedBox(height: 8),
                        // ConstrainedBox(
                        //   constraints: BoxConstraints(
                        //     maxWidth: screenWidth * 0.45,
                        //   ),
                        //   child: ElevatedButton.icon(
                        //     icon: const Icon(Icons.edit, size: 16),
                        //     label: const Text('Edit Profile'),
                        //     onPressed: () {},
                        //     style: ElevatedButton.styleFrom(
                        //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        //       minimumSize: Size.zero,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats section - More responsive layout
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  _buildStatCard((_numberOfBots ?? 0).toString(), 'Bots'),
                  _buildStatCard(
                    _tokenUsage?.unlimited == true
                        ? '∞'
                        : '${_tokenUsage?.availableTokens ?? 0}/${_tokenUsage?.totalTokens ?? 0}',
                    'Tokens',
                  ),
                  _buildStatCard((_numberOfKnowledges ?? 0).toString(), 'Knowledges'),
                ],
              ),
            ),

            // Subscription section with real data
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Subscription',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF202124),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              // child: Text(
                              //   _subscription?.plan?.name ?? 'Free plan',
                              //   style: TextStyle(
                              //     fontSize: 14,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.white,
                              //   ),
                              // ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          // _subscription?.plan?.description ??
                          'Subscribe to send more messages without daily limits and access premium features.',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.bolt, size: 16),
                            label: const Text('Upgrade to Pro'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Menu options - More structured with divider
            const Divider(height: 1, color: Color(0xFF2A2A2A)),
            PressableMenuItemWithArrow(
              title: 'Account Settings',
              subtitle: 'Privacy, Notifications, Appearance',
              onTap: () {},
            ),
            PressableMenuItemWithArrow(
              title: 'Help & Support',
              subtitle: 'Get assistance and report issues',
              onTap: () {},
            ),

            // Sign Out button
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PressableDrawerItem(
                icon: Icons.logout,
                title: 'Sign Out',
                iconColor: Colors.red,
                textColor: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // More efficient stat card builder
  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(4),
        color: Colors.grey[850],
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
