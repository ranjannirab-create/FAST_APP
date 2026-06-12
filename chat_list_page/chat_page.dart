/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '/home_page/user_profile_page.dart';
import '../home_page/image_helper.dart';
import '../services/database_service.dart';

class ChatPage extends StatefulWidget {
  final String targetUserId;

  const ChatPage({super.key, required this.targetUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const Color _brand = Color(0xFF2FA089);
  static const Color _brandDark = Color(0xFF1C7F6B);
  static const List<String> _reactionChoices = [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '😡',
  ];

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final DatabaseService _db = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  late final String currentUserId;
  bool _typingRequestInFlight = false;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    _setTyping(false);
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _setTyping(bool isTyping) async {
    if (_typingRequestInFlight) return;
    _typingRequestInFlight = true;
    try {
      await _db.setTypingStatus(
        chatPartnerId: widget.targetUserId,
        isTyping: isTyping,
      );
    } catch (_) {}
    _typingRequestInFlight = false;
  }

  void _handleTextChanged(String value) {
    final hasText = value.trim().isNotEmpty;
    if (!hasText) {
      _setTyping(false);
      return;
    }

    _setTyping(true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _messageController.text.trim().isEmpty) {
        _setTyping(false);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await _setTyping(false);
    await _db.sendMessage(widget.targetUserId, text);
    _messageController.clear();
    _messageFocusNode.requestFocus();
    _scrollToBottom();
  }

  Future<void> _setReaction(String messageId, String emoji) async {
    try {
      await _db.setMessageReaction(
        otherUserId: widget.targetUserId,
        messageId: messageId,
        emoji: emoji,
      );
    } catch (_) {}
  }

  void _showReactionSheet(String messageId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final emoji in _reactionChoices)
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      Navigator.pop(context);
                      await _setReaction(messageId, emoji);
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfilePage(userId: widget.targetUserId),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final time = TimeOfDay.fromDateTime(dateTime.toLocal());
    return time.format(context);
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Last seen recently';
    final diff = DateTime.now().difference(lastSeen.toLocal());
    if (diff.inMinutes < 1) return 'Last seen just now';
    if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return 'Last seen ${diff.inHours} hours ago';
    return 'Last seen ${diff.inDays} days ago';
  }

  String _statusText(Map<String, dynamic> userData) {
    final isTyping = userData['isTyping'] == true;
    final typingWith = userData['typingWith'];
    if (isTyping && typingWith == currentUserId) {
      return 'Typing...';
    }

    if (DatabaseService.isEffectivelyOnline(userData)) {
      return 'Online';
    }

    final lastActivity = DatabaseService.getLastActivityTime(userData);
    if (lastActivity != null) return _formatLastSeen(lastActivity as DateTime?);
    return 'Offline';
  }

  Widget _buildHeader(Map<String, dynamic> userData) {
    final name = (userData['name'] ?? 'User').toString();
    final profilePic = (userData['profilePic'] ?? '').toString();
    final status = _statusText(userData);

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_brand, _brandDark]),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: InkWell(
              onTap: _openProfile,
              borderRadius: BorderRadius.circular(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    backgroundImage: getProfileImage(profilePic),
                    child: profilePic.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Text(
                            status,
                            key: ValueKey(status),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: status == 'Online'
                                  ? const Color(0xFFE9FFF6)
                                  : Colors.white70,
                              fontSize: 12,
                              fontWeight: status == 'Typing...'
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _openProfile,
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionRow(Map<String, dynamic> reactions, bool isMe) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final values = reactions.values.whereType<String>().toList();
    if (values.isEmpty) return const SizedBox.shrink();

    final counts = <String, int>{};
    for (final emoji in values) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }

    final ordered = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = ordered.first;
    final total = values.length;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black12.withOpacity(0.06)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(top.key, style: const TextStyle(fontSize: 14)),
            if (total > 1) ...[
              const SizedBox(width: 4),
              Text(
                '$total',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    QueryDocumentSnapshot doc,
    Map<String, dynamic> data,
  ) {
    final isMe = data['senderId'] == currentUserId;
    final message = (data['message'] ?? '').toString();
    final timestamp = data['timestamp'];
    final seen = data['seen'] == true;
    final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    final maxWidth = MediaQuery.sizeOf(context).width * 0.76;
    final ownReaction = reactions[currentUserId] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onDoubleTap: () => _setReaction(doc.id, '❤️'),
            onLongPress: () => _showReactionSheet(doc.id),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.96, end: 1),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? _brand : Colors.white,
                    gradient: isMe
                        ? const LinearGradient(
                            colors: [_brand, _brandDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 6),
                      bottomRight: Radius.circular(isMe ? 6 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isMe ? 0.09 : 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: isMe
                        ? null
                        : Border.all(color: Colors.black12.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        style: TextStyle(
                          color: isMe ? Colors.white : const Color(0xFF202124),
                          fontSize: 15,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(
                              timestamp is Timestamp
                                  ? timestamp.toDate()
                                  : null,
                            ),
                            style: TextStyle(
                              color: isMe ? Colors.white70 : Colors.black45,
                              fontSize: 10.5,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 6),
                            Icon(
                              seen ? Icons.done_all : Icons.done,
                              size: 15,
                              color: seen
                                  ? const Color(0xFFBBF7D0)
                                  : Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              seen ? 'Seen' : 'Sent',
                              style: TextStyle(
                                color: seen
                                    ? const Color(0xFFBBF7D0)
                                    : Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (ownReaction != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            ownReaction,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildReactionRow(reactions, isMe),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F5F7),
              borderRadius: BorderRadius.circular(22),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.emoji_emotions_outlined,
                color: Color(0xFF54606A),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE3EAF0)),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                onChanged: _handleTextChanged,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                maxLines: 5,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_brand, _brandDark]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x332FA089),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x1A2FA089), Color(0x002FA089)],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.targetUserId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data() ?? <String, dynamic>{};
                    return _buildHeader(data);
                  },
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _db.getMessages(widget.targetUserId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;
                      final unseenIncomingIds = <String>[];

                      for (final doc in messages) {
                        final data = doc.data() as Map<String, dynamic>;
                        final isIncoming =
                            data['senderId'] == widget.targetUserId &&
                            data['receiverId'] == currentUserId;
                        if (isIncoming && data['seen'] != true) {
                          unseenIncomingIds.add(doc.id);
                        }
                      }

                      if (unseenIncomingIds.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _db.markMessagesAsSeen(
                            otherUserId: widget.targetUserId,
                            messageIds: unseenIncomingIds,
                          );
                        });
                      }

                      _scrollToBottom();

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final doc = messages[index];
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildMessageBubble(context, doc, data);
                        },
                      );
                    },
                  ),
                ),
                _buildComposer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
*/


import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/home_page/user_profile_page.dart';
import '../services/database_service.dart';

class ChatPage extends StatefulWidget {
  final String targetUserId;

  const ChatPage({super.key, required this.targetUserId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const Color _brand = Color(0xFF2FA089);
  static const Color _brandDark = Color(0xFF1C7F6B);
  static const List<String> _reactionChoices = [
    '👍', '❤️', '😂', '😮', '😢', '😡', '🎉', '🔥'
  ];

  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  final DatabaseService _db = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  late final String currentUserId;
  bool _typingRequestInFlight = false;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  @override
  void dispose() {
    _setTyping(false);
    _messageController.dispose();
    _messageFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _setTyping(bool isTyping) async {
    if (_typingRequestInFlight) return;
    _typingRequestInFlight = true;
    try {
      await _db.setTypingStatus(
        chatPartnerId: widget.targetUserId,
        isTyping: isTyping,
      );
    } catch (_) {}
    _typingRequestInFlight = false;
  }

  void _handleTextChanged(String value) {
    final hasText = value.trim().isNotEmpty;
    if (!hasText) {
      _setTyping(false);
      return;
    }
    _setTyping(true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _messageController.text.trim().isEmpty) {
        _setTyping(false);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    await _setTyping(false);
    await _db.sendMessage(widget.targetUserId, text);
    _messageController.clear();
    _messageFocusNode.requestFocus();
    _scrollToBottom();
  }

  Future<void> _setReaction(String messageId, String emoji) async {
    try {
      await _db.setMessageReaction(
        otherUserId: widget.targetUserId,
        messageId: messageId,
        emoji: emoji,
      );
    } catch (_) {}
  }

  void _showReactionSheet(String messageId) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10)),
              ],
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final emoji in _reactionChoices)
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      Navigator.pop(context);
                      await _setReaction(messageId, emoji);
                    },
                    child: Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F8FA),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfilePage(userId: widget.targetUserId),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final time = TimeOfDay.fromDateTime(dateTime.toLocal());
    return time.format(context);
  }

  String _formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return 'Last seen recently';
    final diff = DateTime.now().difference(lastSeen.toLocal());
    if (diff.inMinutes < 1) return 'Last seen just now';
    if (diff.inMinutes < 60) return 'Last seen ${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return 'Last seen ${diff.inHours} hours ago';
    return 'Last seen ${diff.inDays} days ago';
  }

  String _statusText(Map<String, dynamic> userData) {
    final isTyping = userData['isTyping'] == true;
    final typingWith = userData['typingWith'];
    if (isTyping && typingWith == currentUserId) {
      return 'Typing...';
    }
    if (DatabaseService.isEffectivelyOnline(userData)) {
      return 'Online';
    }
    final lastActivity = DatabaseService.getLastActivityTime(userData);
    if (lastActivity != null) return _formatLastSeen(lastActivity as DateTime?);
    return 'Offline';
  }

  Widget _buildHeader(Map<String, dynamic> userData) {
    final name = (userData['name'] ?? 'User').toString();
    final profilePic = (userData['profilePic'] ?? '').toString();
    final status = _statusText(userData);

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [_brand, _brandDark]),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Expanded(
            child: InkWell(
              onTap: _openProfile,
              borderRadius: BorderRadius.circular(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    backgroundImage: _getProfileImage(profilePic),
                    child: profilePic.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: Text(
                            status,
                            key: ValueKey(status),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: status == 'Online' ? const Color(0xFFE9FFF6) : Colors.white70,
                              fontSize: 12,
                              fontWeight: status == 'Typing...' ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: _openProfile,
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage(String? profilePic) {
    if (profilePic == null || profilePic.isEmpty) {
      return const AssetImage('assets/default_avatar.png');
    }
    if (profilePic.startsWith('assets/')) {
      return AssetImage(profilePic);
    }
    return NetworkImage(profilePic);
  }

  Widget _buildReactionRow(Map<String, dynamic> reactions, bool isMe) {
    if (reactions.isEmpty) return const SizedBox.shrink();
    final values = reactions.values.whereType<String>().toList();
    if (values.isEmpty) return const SizedBox.shrink();

    final counts = <String, int>{};
    for (final emoji in values) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }
    final ordered = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = ordered.first;
    final total = values.length;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black12.withOpacity(0.06)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(top.key, style: const TextStyle(fontSize: 14)),
            if (total > 1) ...[
              const SizedBox(width: 4),
              Text('$total', style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(QueryDocumentSnapshot doc, Map<String, dynamic> data) {
    final isMe = data['senderId'] == currentUserId;
    final message = (data['message'] ?? '').toString();
    final timestamp = data['timestamp'];
    final seen = data['seen'] == true;
    final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    final maxWidth = MediaQuery.sizeOf(context).width * 0.76;
    final ownReaction = reactions[currentUserId] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onDoubleTap: () => _setReaction(doc.id, '❤️'),
            onLongPress: () => _showReactionSheet(doc.id),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.96, end: 1),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? _brand : Colors.white,
                    gradient: isMe ? const LinearGradient(colors: [_brand, _brandDark]) : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 6),
                      bottomRight: Radius.circular(isMe ? 6 : 18),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(isMe ? 0.09 : 0.06), blurRadius: 12, offset: const Offset(0, 6))],
                    border: isMe ? null : Border.all(color: Colors.black12.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message,
                        style: TextStyle(color: isMe ? Colors.white : const Color(0xFF202124), fontSize: 15, height: 1.25),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(timestamp is Timestamp ? timestamp.toDate() : null),
                            style: TextStyle(color: isMe ? Colors.white70 : Colors.black45, fontSize: 10.5),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 6),
                            Icon(seen ? Icons.done_all : Icons.done, size: 15, color: seen ? const Color(0xFFBBF7D0) : Colors.white70),
                            const SizedBox(width: 4),
                            Text(seen ? 'Seen' : 'Sent', style: TextStyle(color: seen ? const Color(0xFFBBF7D0) : Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ],
                      ),
                      if (ownReaction != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(ownReaction, style: const TextStyle(fontSize: 18)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildReactionRow(reactions, isMe),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05))),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Row(
        children: [
          // এমোজি বাটন
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF2F5F7), borderRadius: BorderRadius.circular(22)),
            child: IconButton(
              onPressed: () => _showEmojiPicker(),
              icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF54606A)),
            ),
          ),
          const SizedBox(width: 10),
          // টেক্সট ইনপুট
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFE3EAF0)),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _messageFocusNode,
                onChanged: _handleTextChanged,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                maxLines: 5,
                minLines: 1,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // সেন্ড বাটন
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [_brand, _brandDark]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x332FA089), blurRadius: 12, offset: Offset(0, 6))],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
            ),
            itemCount: _reactionChoices.length,
            itemBuilder: (context, index) {
              return IconButton(
                icon: Text(_reactionChoices[index], style: const TextStyle(fontSize: 30)),
                onPressed: () {
                  _messageController.text += _reactionChoices[index];
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Color(0x1A2FA089), Color(0x002FA089)]),
                ),
              ),
            ),
            Column(
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance.collection('users').doc(widget.targetUserId).snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data() ?? <String, dynamic>{};
                    return _buildHeader(data);
                  },
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _db.getMessages(widget.targetUserId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final messages = snapshot.data!.docs;
                      final unseenIncomingIds = <String>[];
                      for (final doc in messages) {
                        final data = doc.data() as Map<String, dynamic>;
                        final isIncoming = data['senderId'] == widget.targetUserId && data['receiverId'] == currentUserId;
                        if (isIncoming && data['seen'] != true) {
                          unseenIncomingIds.add(doc.id);
                        }
                      }
                      if (unseenIncomingIds.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _db.markMessagesAsSeen(otherUserId: widget.targetUserId, messageIds: unseenIncomingIds);
                        });
                      }
                      _scrollToBottom();
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final doc = messages[index];
                          final data = doc.data() as Map<String, dynamic>;
                          return _buildMessageBubble(doc, data);
                        },
                      );
                    },
                  ),
                ),
                _buildComposer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
