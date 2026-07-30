import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/home_controller.dart';

class ChatDetailView extends GetView<HomeController> {
  const ChatDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatThread chat = Get.arguments as ChatThread;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0C0E),
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(chat.imageUrl),
                  radius: 18,
                ),
                Obx(() {
                  if (chat.isOnline.value) {
                    return Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0C0C0E), width: 1.5),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    chat.name.split(',').first,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ACTIVE NOW',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Chat history area
            Expanded(
              child: Obx(() {
                final items = _buildListItems(chat.messages, chat.isTyping.value);
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  reverse: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) => items[index],
                );
              }),
            ),
            
            // Divider
            const Divider(color: AppColors.divider, height: 1),

            // Input panel
            Container(
              color: const Color(0xFF0C0C0E),
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 20),
              child: Row(
                children: [
                  // Left action buttons (+ and Image)
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.textSecondary, size: 24),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo_outlined, color: AppColors.textSecondary, size: 24),
                    onPressed: () {},
                  ),

                  // Text input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.divider, width: 1.0),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.chatInputController,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                hintText: 'Your message...',
                                hintStyle: TextStyle(color: AppColors.textMuted),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (value) => controller.sendMessage(chat),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.sentiment_satisfied_alt_outlined, color: AppColors.textMuted, size: 22),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Voice/mic button
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.mic, color: AppColors.textSecondary, size: 22),
                  ),
                  const SizedBox(width: 8),

                  // Gold send button
                  GestureDetector(
                    onTap: () => controller.sendMessage(chat),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: AppColors.goldGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.2,
                          child: const Icon(
                            Icons.send,
                            color: AppColors.onGold,
                            size: 18,
                          ),
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
    );
  }

  List<Widget> _buildListItems(List<Map<String, dynamic>> messages, bool isTyping) {
    final List<Widget> items = [];

    // If typing is true, add typing indicator at the very bottom (first in reversed list)
    if (isTyping) {
      items.add(const _TypingIndicatorItem());
      // If there are no messages sent today, show TODAY capsule above it
      final hasMessagesToday = messages.any((msg) => msg['date'] == 'TODAY');
      if (!hasMessagesToday) {
        items.add(const _DateSeparatorItem(dateText: 'TODAY', isToday: true));
      }
    }

    // Process messages from most recent (end of list) to oldest (start of list)
    for (int i = messages.length - 1; i >= 0; i--) {
      final currentMsg = messages[i];
      final currentMsgDate = currentMsg['date'] ?? '';

      // Add bubble
      items.add(_MessageBubbleItem(msg: currentMsg));

      // Separate dates: show a separator above the message (i.e. next in the reversed list)
      if (i == 0) {
        if (currentMsgDate.isNotEmpty) {
          items.add(_DateSeparatorItem(
            dateText: currentMsgDate,
            isToday: currentMsgDate == 'TODAY',
          ));
        }
      } else {
        final prevMsg = messages[i - 1];
        final prevMsgDate = prevMsg['date'] ?? '';
        if (currentMsgDate != prevMsgDate && currentMsgDate.isNotEmpty) {
          items.add(_DateSeparatorItem(
            dateText: currentMsgDate,
            isToday: currentMsgDate == 'TODAY',
          ));
        }
      }
    }

    return items;
  }
}

class _DateSeparatorItem extends StatelessWidget {
  final String dateText;
  final bool isToday;
  const _DateSeparatorItem({required this.dateText, required this.isToday});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: isToday
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.divider, width: 1.0),
                ),
                child: Text(
                  'TODAY',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 10,
                  ),
                ),
              )
            : Text(
                dateText.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  fontSize: 10,
                ),
              ),
      ),
    );
  }
}

class _TypingIndicatorItem extends StatefulWidget {
  const _TypingIndicatorItem();

  @override
  State<_TypingIndicatorItem> createState() => _TypingIndicatorItemState();
}

class _TypingIndicatorItemState extends State<_TypingIndicatorItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatThread chat = Get.arguments as ChatThread;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(chat.imageUrl),
            radius: 12,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(0),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final double value = ((_controller.value + delay) % 1.0);
                    final double offset = -4 * (value < 0.5 ? value : (1.0 - value));
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      transform: Matrix4.translationValues(0, offset, 0),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.textSecondary,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubbleItem extends StatelessWidget {
  final Map<String, dynamic> msg;
  const _MessageBubbleItem({required this.msg});

  @override
  Widget build(BuildContext context) {
    final bool isMe = msg['sender'] == 'me';
    final ChatThread chat = Get.arguments as ChatThread;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF16161A) : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    border: isMe ? Border.all(color: AppColors.gold, width: 1.0) : null,
                  ),
                  child: Text(
                    msg['text'] ?? '',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isMe ? AppColors.gold : AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: isMe
                  ? [
                      Text(
                        msg['time'] ?? '',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.done_all,
                        color: AppColors.gold,
                        size: 14,
                      ),
                    ]
                  : [
                      CircleAvatar(
                        backgroundImage: NetworkImage(chat.imageUrl),
                        radius: 10,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        msg['time'] ?? '',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textMuted,
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
