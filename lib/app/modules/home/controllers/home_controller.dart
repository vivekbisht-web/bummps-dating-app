import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/storage/secure_storage_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_profile.dart';

/// Representation of a discover profile card.
class ProfileCardData {
  final String name;
  final int age;
  final String job;
  final String distance;
  final String bio;
  final String id;
  final String matchScore;
  final String imageUrl;
  final bool isVerified;
  final String location;
  final String height;
  final String education;
  final String languages;
  final List<String> interests;
  final List<String> lifestyle;

  ProfileCardData({
    required this.name,
    required this.age,
    required this.job,
    required this.distance,
    required this.bio,
    required this.id,
    required this.matchScore,
    required this.imageUrl,
    this.isVerified = true,
    required this.location,
    required this.height,
    required this.education,
    required this.languages,
    required this.interests,
    required this.lifestyle,
  });
}

/// Representation of a chat thread.
class ChatThread {
  final String id;
  final String name;
  final String imageUrl;
  final RxString lastMessage;
  final RxString time;
  final RxList<Map<String, dynamic>> messages;
  final RxBool isUnread;
  final RxBool isOnline;
  final RxBool isTyping;

  ChatThread({
    required this.id,
    required this.name,
    required this.imageUrl,
    required String initialMessage,
    required String initialTime,
    bool unread = false,
    bool online = false,
    bool typing = false,
  })  : lastMessage = initialMessage.obs,
        time = initialTime.obs,
        isUnread = unread.obs,
        isOnline = online.obs,
        isTyping = typing.obs,
        messages = <Map<String, dynamic>>[
          {'text': initialMessage, 'sender': 'them', 'time': initialTime}
        ].obs;
}

class HomeController extends GetxController with GetSingleTickerProviderStateMixin {
  // Navigation Tabs state
  final RxInt activeTab = 0.obs;

  // Swiping Card Stack state
  final RxList<ProfileCardData> profiles = <ProfileCardData>[].obs;
  final RxList<ProfileCardData> swipeHistory = <ProfileCardData>[].obs;
  
  // Card drag coordinates
  final RxDouble cardX = 0.0.obs;
  final RxDouble cardY = 0.0.obs;
  
  // Slide out animations triggers/flags
  final RxDouble swipeOverlayOpacity = 0.0.obs; // Opacity of swipe label overlay (like/nope)
  final RxString swipeDirection = ''.obs; // 'like', 'nope', 'super'

  // Boost simulation state
  final RxBool isBoostActive = false.obs;
  final RxInt boostTimeLeft = 0.obs;

  // Active User Feed API Integration
  final RxBool isLoadingFeed = false.obs;

  // Matches list
  final RxList<ProfileCardData> matches = <ProfileCardData>[].obs;
  final List<ProfileCardData> likesYouList = [];

  // Messages list
  final RxList<ChatThread> chatThreads = <ChatThread>[].obs;

  // Text controller for chat inputs
  final TextEditingController chatInputController = TextEditingController();

  // Active User Profile API Integration
  final Rxn<UserProfile> currentUserProfile = Rxn<UserProfile>();
  final RxBool isLoadingProfile = false.obs;

  Future<void> fetchUserProfile() async {
    try {
      isLoadingProfile.value = true;
      final storage = Get.find<SecureStorageService>();
      final userId = await storage.getUserId();
      if (userId != null && userId.isNotEmpty) {
        final authRepo = Get.find<AuthRepository>();
        final profile = await authRepo.getProfile(userId);
        currentUserProfile.value = profile;
      }
    } catch (e) {
      debugPrint('[HomeController] Error fetching user profile: $e');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
    _loadInitialProfiles();
    _loadLikesYouList();
    _loadInitialMatches();
    _loadInitialChats();
  }

  Future<void> _loadInitialProfiles() async {
    try {
      isLoadingFeed.value = true;
      profiles.clear();
      final authRepo = Get.find<AuthRepository>();
      final feedList = await authRepo.getFeed();
      final mapped = feedList.map((up) {
        String picUrl = up.profilePic;
        if (picUrl.isEmpty) {
          picUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=80';
        } else if (!picUrl.startsWith('http') && !picUrl.startsWith('assets/')) {
          picUrl = picUrl.startsWith('/')
              ? 'https://datingapp-oz22.onrender.com$picUrl'
              : 'https://datingapp-oz22.onrender.com/$picUrl';
        }

        return ProfileCardData(
          id: up.id,
          name: up.name,
          age: up.age,
          job: up.jobTitle.isNotEmpty ? up.jobTitle : 'Software Engineer',
          distance: '${up.distancePreference} miles away',
          bio: up.bio.isNotEmpty ? up.bio : 'Hello! I\'m looking for real connections.',
          matchScore: '95',
          imageUrl: picUrl,
          isVerified: up.isVerified,
          location: up.livingIn.isNotEmpty ? up.livingIn : 'New Delhi',
          height: up.height.isNotEmpty ? '${up.height} cm' : '165 cm',
          education: up.school.isNotEmpty ? up.school : 'Delhi University',
          languages: up.languages.isNotEmpty ? up.languages.join(', ') : 'EN',
          interests: up.interests,
          lifestyle: up.lifestyle.isNotEmpty ? up.lifestyle : const ['Non-smoker', 'Social Drinker', 'Dog Lover'],
        );
      }).toList();
      profiles.addAll(mapped);
    } catch (e) {
      debugPrint('[HomeController] Error loading discovery feed: $e');
    } finally {
      isLoadingFeed.value = false;
    }
  }

  void _loadLikesYouList() {
    likesYouList.addAll([
      ProfileCardData(
        name: 'Charlotte',
        age: 28,
        job: 'Haute Couture Designer',
        distance: '1 mile away',
        bio: 'Fascinated by texture, form, and lines. Let\'s draft a connection.',
        id: 'SS_0920',
        matchScore: '97',
        imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&auto=format&fit=crop&q=80',
        location: 'Paris, France',
        height: '165 cm',
        education: 'IFM Paris',
        languages: 'FR, EN',
        interests: ['Photography', 'Travel'],
        lifestyle: ['Non-smoker'],
      ),
      ProfileCardData(
        name: 'Aria',
        age: 30,
        job: 'Neurologist',
        distance: '6 miles away',
        bio: 'Deciphering the human brain, yet curious about matters of the heart.',
        id: 'SS_0733',
        matchScore: '94',
        imageUrl: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=400&auto=format&fit=crop&q=80',
        location: 'Boston, USA',
        height: '170 cm',
        education: 'Harvard Medical',
        languages: 'EN, ES',
        interests: ['Classical Music', 'Travel'],
        lifestyle: ['Non-smoker'],
      ),
    ]);
  }

  void _loadInitialMatches() {
    matches.addAll([
      ProfileCardData(
        name: 'Elena',
        age: 28,
        job: 'Art Curator',
        distance: '5 miles away',
        bio: 'Seeking a connection...',
        id: 'SS_0192',
        matchScore: '95',
        imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
        location: 'Paris, France',
        height: '175 cm',
        education: 'Sorbonne',
        languages: 'FR, EN, IT',
        interests: ['Photography', 'Travel'],
        lifestyle: ['Cat Lover'],
      ),
      ProfileCardData(
        name: 'Marcus',
        age: 32,
        job: 'Fine Art Curator',
        distance: '3 miles away',
        bio: 'Passionate about aesthetic storytelling...',
        id: 'SS_0571',
        matchScore: '89',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
        location: 'London, UK',
        height: '182 cm',
        education: 'Courtauld Institute',
        languages: 'EN, FR',
        interests: ['Photography', 'Architecture'],
        lifestyle: ['Dog Lover'],
      ),
      ProfileCardData(
        name: 'Sophia',
        age: 29,
        job: 'Boutique Architect',
        distance: '4 miles away',
        bio: 'Designing space...',
        id: 'SS_0442',
        matchScore: '92',
        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
        location: 'Milan, Italy',
        height: '168 cm',
        education: 'Politecnico',
        languages: 'IT, EN',
        interests: ['Architecture', 'Travel'],
        lifestyle: ['Cat Lover'],
      ),
      ProfileCardData(
        name: 'Julian',
        age: 31,
        job: 'Venture Capitalist',
        distance: '2 miles away',
        bio: 'Seeking intellectual depth...',
        id: 'SS_0835',
        matchScore: '98',
        imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&auto=format&fit=crop&q=80',
        location: 'New York, USA',
        height: '170 cm',
        education: 'Wharton School',
        languages: 'EN, FR',
        interests: ['Photography', 'Travel'],
        lifestyle: ['Non-smoker'],
      ),
      ProfileCardData(
        name: 'Kai',
        age: 27,
        job: 'Creative Director',
        distance: '1 mile away',
        bio: 'Exploring expressions...',
        id: 'SS_0990',
        matchScore: '93',
        imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&auto=format&fit=crop&q=80',
        location: 'Berlin, Germany',
        height: '178 cm',
        education: 'UdK Berlin',
        languages: 'DE, EN',
        interests: ['Photography', 'Travel'],
        lifestyle: ['Non-smoker'],
      ),
    ]);
  }

  void _loadInitialChats() {
    chatThreads.addAll([
      ChatThread(
        id: '1',
        name: 'Maya',
        imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&auto=format&fit=crop&q=80',
        initialMessage: 'That sounds like a perfect plan for Saturday! ☕',
        initialTime: '12:45 PM',
        unread: true,
        online: true,
      ),
      ChatThread(
        id: '2',
        name: 'David',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
        initialMessage: 'I really enjoyed that documentary too!',
        initialTime: 'Yesterday',
      ),
      ChatThread(
        id: '3',
        name: 'Chloe',
        imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
        initialMessage: 'How was your weekend hiking trip?',
        initialTime: 'Yesterday',
      ),
      ChatThread(
        id: '4',
        name: 'Alex',
        imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&auto=format&fit=crop&q=80',
        initialMessage: 'Haha, that\'s hilarious! I can\'t believe that happened.',
        initialTime: 'Tuesday',
      ),
      ChatThread(
        id: '5',
        name: 'Sarah',
        imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
        initialMessage: 'Let me know if you want the link to that playlist.',
        initialTime: 'Monday',
      ),
    ]);
  }

  // --- Swiping Deck Actions ---

  void updateCardPosition(double dx, double dy) {
    cardX.value = dx;
    cardY.value = dy;

    // Calculate overlay opacity based on drag distance
    final double dist = sqrt(dx * dx + dy * dy);
    swipeOverlayOpacity.value = min(dist / 120.0, 1.0);

    if (dx > 20) {
      swipeDirection.value = 'like';
    } else if (dx < -20) {
      swipeDirection.value = 'nope';
    } else if (dy < -20) {
      swipeDirection.value = 'super';
    } else {
      swipeDirection.value = '';
    }
  }

  void handlePanEnd(double velocityX, double velocityY) {
    // If dragged beyond threshold (120px) or high velocity
    if (cardX.value > 120 || velocityX > 400) {
      _executeSwipeAction('like');
    } else if (cardX.value < -120 || velocityX < -400) {
      _executeSwipeAction('nope');
    } else if (cardY.value < -100 || velocityY < -400) {
      _executeSwipeAction('super');
    } else {
      // Snap back to center
      cardX.value = 0;
      cardY.value = 0;
      swipeOverlayOpacity.value = 0;
      swipeDirection.value = '';
    }
  }

  void _executeSwipeAction(String action) async {
    if (profiles.isEmpty) return;

    final ProfileCardData profile = profiles.first;
    swipeDirection.value = action;
    swipeOverlayOpacity.value = 1.0;

    // Target coordinates to animate card sliding off the screen
    double targetX = 0;
    double targetY = 0;
    
    if (action == 'like') {
      targetX = 600;
    } else if (action == 'nope') {
      targetX = -600;
    } else if (action == 'super') {
      targetY = -800;
    }

    // Direct assignment to simulate slide-off then remove
    cardX.value = targetX;
    cardY.value = targetY;

    await Future.delayed(const Duration(milliseconds: 200));

    // Move to history
    swipeHistory.add(profile);
    profiles.removeAt(0);

    // Reset card coordinates for next card
    cardX.value = 0;
    cardY.value = 0;
    swipeOverlayOpacity.value = 0;
    swipeDirection.value = '';

    // Action reactions
    if (action == 'like' || action == 'super') {
      // Simulate random matching for a premium feel
      // We will trigger a match dialog for Julien (1st profile) or Elena (2nd profile) or randomly 40% of the time.
      if (profile.name == 'Julien' || profile.name == 'Elena' || Random().nextDouble() < 0.40) {
        _triggerMatchDialog(profile);
      }
    }
  }

  void forceSwipe(String direction) {
    _executeSwipeAction(direction);
  }

  void undoSwipe() {
    if (swipeHistory.isEmpty) {
      Get.snackbar(
        'Bummps Rewind',
        'No swiping history to rewind.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface,
        colorText: AppColors.textPrimary,
      );
      return;
    }

    final ProfileCardData restoredProfile = swipeHistory.removeLast();
    profiles.insert(0, restoredProfile);
  }

  void triggerBoost() {
    if (isBoostActive.value) return;

    isBoostActive.value = true;
    boostTimeLeft.value = 1800; // 30 minutes in seconds

    Get.snackbar(
      'PROFILE BOOSTED',
      'Your profile is now in the spotlight for 30 minutes.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.gold,
      colorText: AppColors.onGold,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.flash_on, color: AppColors.onGold),
    );

    // Start a simulated timer
    _runBoostTimer();
  }

  void _runBoostTimer() async {
    while (boostTimeLeft.value > 0 && isBoostActive.value) {
      await Future.delayed(const Duration(seconds: 1));
      boostTimeLeft.value--;
    }
    isBoostActive.value = false;
  }

  // --- Match Dialog ---

  void _triggerMatchDialog(ProfileCardData profile) {
    // Add to matches list
    if (!matches.contains(profile)) {
      matches.insert(0, profile);
    }

    // Add a corresponding chat thread
    final String chatName = '${profile.name}, ${profile.age}';
    final bool exists = chatThreads.any((element) => element.name == chatName);
    if (!exists) {
      final newChat = ChatThread(
        id: profile.id,
        name: chatName,
        imageUrl: profile.imageUrl,
        initialMessage: profile.name == 'Elena'
            ? "I'd love to continue that discussion over dinner. I know a quiet spot that would be perfect."
            : 'You matched! Say hello to ${profile.name}.',
        initialTime: profile.name == 'Elena' ? '10:18 PM' : 'Just Now',
        online: true,
        typing: profile.name == 'Elena',
      );
      if (profile.name == 'Elena') {
        newChat.messages.assignAll([
          {
            'text': 'It was a pleasure meeting you at the gala last night. The collection was truly inspiring.',
            'sender': 'them',
            'time': '10:14 PM',
            'date': 'MONDAY, OCTOBER 24',
          },
          {
            'text': 'Likewise, Elena. I particularly enjoyed our conversation regarding the minimalist influence on modern horology.',
            'sender': 'me',
            'time': '10:16 PM',
            'date': 'MONDAY, OCTOBER 24',
          },
          {
            'text': "I'd love to continue that discussion over dinner. I know a quiet spot that would be perfect.",
            'sender': 'them',
            'time': '10:18 PM',
            'date': 'MONDAY, OCTOBER 24',
          },
        ]);
      }
      chatThreads.insert(0, newChat);
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withOpacity(0.92),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Glittering Gold Particle Simulator
              Icon(Icons.stars, color: AppColors.gold, size: 72),
              const SizedBox(height: 16),
              Text(
                'IT\'S A MATCH!',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.gold,
                  fontSize: 34,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your souls are vibrating at the same frequency.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 48),

              // Overlapping profile images
              SizedBox(
                width: 260,
                height: 150,
                child: Stack(
                  children: [
                    // Left image (Self dummy - using onboarding image or placeholder)
                    Positioned(
                      left: 10,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 3),
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&auto=format&fit=crop&q=80'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Right image (Matched profile)
                    Positioned(
                      right: 10,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.gold, width: 3),
                          image: DecorationImage(
                            image: NetworkImage(profile.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // CTA buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      activeTab.value = 2; // Jump to Messages
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'SEND A MESSAGE',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'KEEP SWIPING',
                  style: AppTextStyles.button.copyWith(color: AppColors.gold, letterSpacing: 1.0),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // --- Messaging Chat Detail View ---

  void openChatDetail(ChatThread chat) {
    Get.toNamed(Routes.chatDetail, arguments: chat);
  }

  ChatThread getOrCreateChatThread(ProfileCardData match) {
    final chatName = '${match.name}, ${match.age}';
    final existingChat = chatThreads.firstWhereOrNull(
      (element) => element.name.startsWith(match.name),
    );
    if (existingChat != null) {
      return existingChat;
    }

    // Create new chat thread
    final newChat = ChatThread(
      id: match.id,
      name: chatName,
      imageUrl: match.imageUrl,
      initialMessage: match.name == 'Elena'
          ? "I'd love to continue that discussion over dinner. I know a quiet spot that would be perfect."
          : 'You matched! Say hello to ${match.name}.',
      initialTime: match.name == 'Elena' ? '10:18 PM' : 'Just Now',
      online: true,
      typing: match.name == 'Elena',
    );

    if (match.name == 'Elena') {
      newChat.messages.assignAll([
        {
          'text': 'It was a pleasure meeting you at the gala last night. The collection was truly inspiring.',
          'sender': 'them',
          'time': '10:14 PM',
          'date': 'MONDAY, OCTOBER 24',
        },
        {
          'text': 'Likewise, Elena. I particularly enjoyed our conversation regarding the minimalist influence on modern horology.',
          'sender': 'me',
          'time': '10:16 PM',
          'date': 'MONDAY, OCTOBER 24',
        },
        {
          'text': "I'd love to continue that discussion over dinner. I know a quiet spot that would be perfect.",
          'sender': 'them',
          'time': '10:18 PM',
          'date': 'MONDAY, OCTOBER 24',
        },
      ]);
    }

    chatThreads.insert(0, newChat);
    return newChat;
  }

  void sendMessage(ChatThread chat) {
    final text = chatInputController.text.trim();
    if (text.isEmpty) return;

    chatInputController.clear();
    
    // Add my message
    final String time = _formatCurrentTime();
    chat.messages.add({
      'text': text, 
      'sender': 'me', 
      'time': time,
      'date': 'TODAY'
    });
    chat.lastMessage.value = text;
    chat.time.value = time;
    chat.isTyping.value = false;

    // Simulate automatic reply after 1.5 seconds for a premium interactive feel
    _simulateReply(chat, text);
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  void _simulateReply(ChatThread chat, String myMessage) async {
    // Wait for the user to read
    await Future.delayed(const Duration(milliseconds: 1000));
    chat.isTyping.value = true;
    
    // Wait for typing animation
    await Future.delayed(const Duration(milliseconds: 2500));
    
    String replyText = "That sounds fascinating! Tell me more about your thoughts.";
    final msgLower = myMessage.toLowerCase();
    if (msgLower.contains('hello') || msgLower.contains('hi')) {
      replyText = "Hi there! I was hoping you'd say hello. How is your day going?";
    } else if (msgLower.contains('design') || msgLower.contains('tech') || msgLower.contains('developer')) {
      replyText = "Fascinating. I really appreciate people with a strong sense of creation and precision.";
    } else if (msgLower.contains('meet') || msgLower.contains('date') || msgLower.contains('coffee')) {
      replyText = "I'd love to organize a meeting! Let's find a beautiful quiet spot.";
    }

    final String time = _formatCurrentTime();
    chat.messages.add({
      'text': replyText, 
      'sender': 'them', 
      'time': time,
      'date': 'TODAY'
    });
    chat.lastMessage.value = replyText;
    chat.time.value = time;
    chat.isTyping.value = false;
  }

  // --- Tab Profile Options ---

  void logout() {
    Get.offAllNamed(Routes.onboarding);
  }

  void editProfile() {
    Get.toNamed(Routes.profileSetup);
  }
}
