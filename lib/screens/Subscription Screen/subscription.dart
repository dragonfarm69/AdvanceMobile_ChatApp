import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/services/userInfo.dart';
import '../../features/model/user.dart';
import '../../features/model/subscription.dart';
import '../../features/model/tokenUsage.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final Userinfo _userInfo = Userinfo();
  User? _user;
  Subscription? _subscription;
  TokenUsage? _tokenUsage;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final user = await _userInfo.getUserInfo();
      final subscription = await _userInfo.getSubscription();
      final tokenUsageInfo = await _userInfo.getTokenUsage();

      if (mounted) {
        setState(() {
          _user = user;
          _subscription = subscription;
          _tokenUsage = tokenUsageInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is being fetched
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text(
            'Your Subscription',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF1E1E1E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error message if something went wrong
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          title: const Text(
            'Your Subscription',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF1E1E1E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    // Calculate token usage percentage
    String tokenDisplay;
    double usagePercent;

    if (_tokenUsage?.unlimited == true) {
      tokenDisplay = "∞";
      usagePercent = 1.0; // Full bar for unlimited
    } else {
      final int usedTokens = _tokenUsage?.availableTokens ?? 0;
      final int totalTokens = _tokenUsage?.totalTokens ?? 30;
      tokenDisplay = "$usedTokens / $totalTokens";
      usagePercent = totalTokens > 0 ? usedTokens / totalTokens : 0.0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Your Subscription',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1E1E1E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account Section
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.account_circle,
                            color: Colors.indigo,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Your Account',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Email',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: TextEditingController(
                          text: _user?.email ?? 'Not available',
                        ),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.grey,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2A2A2A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Plan Section
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF2C3E50), const Color(0xFF4A69BD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Plan',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _subscription?.name ?? 'Basic',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Unlimited token',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Icon(
                            Icons.check_circle,
                            color: Colors.greenAccent,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'More advance features',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.upgrade),
                          label: const Text('Upgrade to Jarvis Pro'),
                          onPressed: () async {
                            // Fix: Use a more explicit approach to launch URLs
                            final Uri url = Uri.parse(
                              'https://dev.jarvis.cx/pricing',
                            );
                            try {
                              // Try using externalApplication mode which is more reliable
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } catch (e) {
                              // If that fails, show a more descriptive error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not open browser: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.indigo[700],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Token Usage Section
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.data_usage,
                            color: Colors.indigo,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Token Usage',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'We enforce token usage limits according to your plan. If you hit the cap, you have the option to upgrade to a higher plan or wait until the following day.',
                        style: TextStyle(color: Colors.grey, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Today Usage',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            tokenDisplay,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: usagePercent,
                          minHeight: 10,
                          backgroundColor: const Color(0xFF2A2A2A),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _tokenUsage?.unlimited == true
                                ? Colors.green
                                : (usagePercent < 0.7
                                    ? Colors.indigo[400]!
                                    : (usagePercent < 0.9
                                        ? Colors.amber
                                        : Colors.redAccent)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.indigo[400],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Used',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A2A2A),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Remaining',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
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
}
