import 'package:flutter/material.dart';
import '../../Components/MenuSideBar.dart';
import '../../Components/CreateBotDialogue.dart';
import '../../features/services/bot_management.dart';
import '../../Classes/bot.dart';
import '../../Classes/createBotRequest.dart';
import 'botDetail.dart';
import '../Chat Screen/ChatScreen.dart';
import '../../features/services/ai_chat.dart';
import '../../features/model/assistant.dart';

/// A stateful version of BotsScreen that supports adding, viewing details, and deleting bots.
class BotsScreen extends StatefulWidget {
  const BotsScreen({Key? key}) : super(key: key);

  @override
  _BotsScreenState createState() => _BotsScreenState();
}

class _BotsScreenState extends State<BotsScreen> {
  final BotManagement _botService = BotManagement();
  List<Bot> _bots = [];
  Bot? _selectedBot;

  @override
  void initState() {
    super.initState();
    _loadBots();
  }

  Future<void> _startChatWithBot(Bot bot) async {
    // Show loading indicator
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Text('Starting new chat...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      // Create an Assistant object from the bot
      final assistant = Assistant(
        name: bot.assistantName ?? 'Unknown Bot',
        id: 'gpt-4o-mini', // Default model, you might want to map bot type to model
        model: 'dify',
      );

      // Create a new chat session
      final aiChat = AiChat();
      final response = await aiChat.newChat('Hello ' + assistant.name, assistant);

      if (response != null && response.containsKey('conversationId')) {
        final conversationId = response['conversationId'] as String;

        // Navigate to the chat screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversationId: conversationId),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Failed to create chat session'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error creating chat: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateBot() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Update ${_selectedBot!.assistantName}?'),
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
        _selectedBot!.assistantName!,
        _selectedBot!.instructions,
        _selectedBot!.description!,
        _selectedBot!.id!,
      );

      // Refresh bots list
      final updatedBots = await _botService.getPublicBots();
      setState(() {
        _bots = updatedBots;
        _selectedBot = _bots.firstWhere((b) => b.id == _selectedBot!.id);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bot updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _loadBots() async {
    final bots = await _botService.getPublicBots();
    setState(() {
      _bots = bots;
    });
  }

  Future<void> _addBot() async {
    final newBot = await showDialog<CreateBotRequest>(
      context: context,
      builder: (_) => const CreateBotDialog(),
    );
    if (newBot != null) {
      // await _botService.addBot();
      print('Test: $newBot');
      print('Test: ${newBot.name}');
      print('Test: ${newBot.instructions}');
      print('Test: ${newBot.description}');

      await _botService.addBot(
        newBot.name,
        newBot.instructions,
        newBot.description,
      );

      //refetch the bots list after adding a new bot
      final bots = await _botService.getPublicBots();
      setState(() {
        _bots = bots;
      });

      // setState(() {
      //   // _bots.add(newBot);
      // });
    }
  }

  void _viewBotDetail(Bot bot) {
    setState(() {
      _selectedBot = bot;
    });
  }

  Future<void> _deleteBot(Bot bot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Delete ${bot.assistantName}?'),
            content: const Text('Are you sure you want to delete this bot?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await _botService.deleteBot(bot.id!);
      setState(() {
        _bots.remove(bot);
        if (_selectedBot == bot) _selectedBot = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: menuSideBar(context),
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child:
              _selectedBot == null
                  ? _buildListView(context)
                  : BotDetailView(
                    bot: _selectedBot!,
                    onDelete: (bot) => _deleteBot(bot),
                    onUpdate: () => _updateBot(),
                    onBack: () {
                      setState(() {
                        _selectedBot = null;
                      });
                    },
                  ),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildHeader(),
        const SizedBox(height: 20),
        _buildSearchBar(),
        const SizedBox(height: 16),
        _buildFilterRow(context),
        const SizedBox(height: 20),
        Expanded(
          child:
              _bots.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                    itemCount: _bots.length,
                    itemBuilder: (ctx, i) {
                      final bot = _bots[i];
                      return Dismissible(
                        key: ValueKey(bot.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        // confirmDismiss: (_) => _deleteBot(bot),
                        child: _buildBotTile(bot),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder:
              (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Bots',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (query) {
                setState(() {
                  if (query.isEmpty) {
                    // If search is empty, restore original list
                    _loadBots();
                  } else {
                    // Filter bots based on name or description
                    _bots = _bots.where((bot) {
                      final nameLower = bot.assistantName?.toLowerCase() ?? '';
                      final descLower = bot.description?.toLowerCase() ?? '';
                      final searchLower = query.toLowerCase();
                      
                      return nameLower.contains(searchLower) || 
                             descLower.contains(searchLower);
                    }).toList();
                  }
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search bots...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'All Bots',
                  style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: _addBot,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy, size: 20, color: Colors.white),
                SizedBox(width: 4),
                Icon(Icons.add, size: 20, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBotTile(Bot bot) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Material(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 25,
            child: Text(
              bot.assistantName!.substring(0, 1),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          title: Text(
            bot.assistantName ?? 'Unknown Bot',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            bot.description ?? 'No description',
            style: TextStyle(color: Colors.grey[400]),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit, color: Color.fromARGB(255, 0, 144, 240)),
            onPressed: () => _viewBotDetail(bot),
          ),
          onTap: () => _startChatWithBot(bot),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(Icons.smart_toy, size: 60, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          Text(
            'No Bots Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create a new bot to get started',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create New Bot'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C6BC0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: _addBot,
          ),
        ],
      ),
    );
  }
}
