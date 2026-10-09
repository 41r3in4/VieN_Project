import 'package:flutter/material.dart';

class CommunityChatScreen extends StatefulWidget {
  final String userEmail;

  const CommunityChatScreen({super.key, required this.userEmail});

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      senderName: 'Nguyễn Văn A',
      senderTitle: 'Đội Viên Khai Phá ⚔️',
      avatarText: 'A',
      message:
          'Mình vừa check-in ở Ngọ Môn xong, nhận được danh hiệu Đội Viên rồi! ⚔️',
      isMine: false,
    ),
    _ChatMessage(
      senderName: 'Lê Thị B',
      senderTitle: 'Nghiên Cứu Di Tích 🌟',
      avatarText: 'B',
      message:
          'Filter Cung Đình Huế chụp ảnh nhìn hoài cổ xịn đét mọi người ơi! 🌟',
      isMine: false,
    ),
    _ChatMessage(
      senderName: 'Trần C',
      senderTitle: 'Người Gác Thành 🛡️',
      avatarText: 'C',
      message:
          'Có ai đang ở Đại Nội không, lập đội đi quét vị trí làm nhiệm vụ chung đi!',
      isMine: false,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          senderName: widget.userEmail.isNotEmpty ? widget.userEmail : 'Bạn',
          senderTitle: 'Khách Du Lịch Mới ✨',
          avatarText: 'T',
          message: message,
          isMine: true,
        ),
      );
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        title: const Text('Box Chat Cộng Đồng'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isMine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: message.isMine
                          ? const Color(0xFFFFE0B2)
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(message.isMine ? 18 : 4),
                        bottomRight: Radius.circular(message.isMine ? 4 : 18),
                      ),
                      border: Border.all(
                        color: Colors.deepOrange.withOpacity(0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: message.isMine
                                  ? Colors.deepOrange
                                  : Colors.amber,
                              child: Text(
                                message.avatarText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.senderName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    message.senderTitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(message.message),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Nhắn gì đó với cộng đồng...',
                      filled: true,
                      fillColor: const Color(0xFFF9F6F0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepOrange,
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                    tooltip: 'Gửi',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String senderName;
  final String senderTitle;
  final String avatarText;
  final String message;
  final bool isMine;

  const _ChatMessage({
    required this.senderName,
    required this.senderTitle,
    required this.avatarText,
    required this.message,
    required this.isMine,
  });
}
