import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controller/sms_controller.dart';
import 'Bottom.dart';
import 'message_details.dart';

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();

  void _handleTapOutside() {
    if (_searchController.text.isEmpty) {
      _searchFocusNode.unfocus();
    } else {
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.unfocus();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Consumer(
        builder: (context, ref, child) {
          return GestureDetector(
            onTap: _handleTapOutside,
            child: Scaffold(
              appBar: AppBar(
                toolbarHeight: 70,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo.png", height: 30,color: Colors.black,),
                    const Text(
                      'Phish Scan',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    SizedBox(width: 27,)
                  ],
                ),
                elevation: 0,
                leading: Container(),
                centerTitle: true,
                  bottom: const TabBar(
                    labelColor: Color(0xFF9636E2),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFF9636E2),
                    tabs: [
                      Tab(text: 'All Messages'),
                      Tab(text: 'Phishing Detected'),
                    ],
                  ),

              ),
              body: Column(
                children: [

                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      focusNode: _searchFocusNode,
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search messages...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        MessageList(showPhishingOnly: false, searchQuery: searchQuery),
                        MessageList(showPhishingOnly: true, searchQuery: searchQuery),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: BottomNavBar(selectedIndex: 1),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Color(0xFF9636E2),
                child: Icon(Icons.refresh),
                onPressed: () async {
                  await ref.read(smsProvider.notifier).refreshMessages();
                },
              ),
            ),
          );
        },
      ),
    );
  }

}

class MessageList extends ConsumerStatefulWidget {
  final bool showPhishingOnly;
  final String searchQuery;

  const MessageList({super.key, required this.showPhishingOnly, required this.searchQuery});

  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<MessageList> {
  @override
  Widget build(BuildContext context) {
    final smsMessages = ref.watch(smsProvider);
    debugPrint("Current state: $smsMessages");

    return smsMessages.when(

      data: (messages) {
        debugPrint("Data received: ${messages.length} messages");

        if (messages.isEmpty ) {
          return const Center(child: CircularProgressIndicator());
        }


        var filteredMessages = widget.showPhishingOnly
            ? messages.where((sms) => sms.prediction == "Phishing").toList()
            : messages;


        if (widget.searchQuery.isNotEmpty) {
          filteredMessages = filteredMessages
              .where((sms) =>
          sms.body.toLowerCase().contains(widget.searchQuery) ||
              sms.sender.toLowerCase().contains(widget.searchQuery))
              .toList();
        }

        if (filteredMessages.isEmpty) {
          return const Center(child: Text('No messages found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: filteredMessages.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            filteredMessages.sort((a, b) => b.date.compareTo(a.date));
            final sms = filteredMessages[index];

            return ListTile(
              title: Text(
                sms.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(sms.sender),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(sms.date),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sms.prediction == "Legitimate" ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sms.prediction,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
              onTap: () {
                String smsId = sms.id ?? "default_id";
                debugPrint("Debug: Before calling updateSmsDetails, SMS ID = $smsId");

                ref.read(smsDetailsProvider.notifier).updateSmsDetails(
                  smsId,
                  sms.body,
                  sms.sender,
                  DateFormat('yyyy-MM-dd HH:mm').format(sms.date),
                  sms.prediction,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SmsDetailsPage()),
                );
              },
            );
          },
        );
      },
      loading: () {
        debugPrint("Loading state triggered");
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stack) {
        debugPrint("Error state: $error");
        return Center(child: Text('Error: $error'));
      },
    );
  }
}
