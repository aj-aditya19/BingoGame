import 'package:flutter/material.dart';
import '../services/socket_service.dart';
import '../theme/app_theme.dart';

class ChatBox extends StatefulWidget {
  final String roomId;
  final String myUserId;
  final String myName;

  const ChatBox({
    super.key,
    required this.roomId,
    required this.myUserId,
    required this.myName,
  });

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  bool isOpen = true;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();

    SocketService.socket.on("chat:receive", _handleReceive);
  }

  @override
  void dispose() {
    SocketService.socket.off("chat:receive", _handleReceive);
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _handleReceive(data) {
    setState(() {
      messages.add(Map<String, dynamic>.from(data));
      if (!isOpen) {
        unreadCount++;
      }
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    SocketService.socket.emit("chat:send", {
      "roomId": widget.roomId,
      "message": text,
      "senderId": widget.myUserId,
      "senderName": widget.myName,
    });

    textController.clear();
  }

  void _toggleOpen() {
    setState(() {
      isOpen = !isOpen;
      if (isOpen) unreadCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.accent2;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: _toggleOpen,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: primary,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Match Chat",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (!isOpen && unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        "$unreadCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Icon(
                    isOpen ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          if (isOpen) ...[
            SizedBox(
              height: 180,
              child: messages.isEmpty
                  ? Center(
                      child: Text(
                        "Say hi to your opponent 👋",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMine = msg["senderId"] == widget.myUserId;

                        return Align(
                          alignment: isMine
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.65,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isMine ? primary : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg["senderName"] ?? "Player",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isMine ? Colors.white70 : primary,
                                  ),
                                ),
                                Text(
                                  msg["message"] ?? "",
                                  style: TextStyle(
                                    color: isMine
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                if (msg["time"] != null)
                                  Text(
                                    msg["time"],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMine
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        counterText: "",
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: primary,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
