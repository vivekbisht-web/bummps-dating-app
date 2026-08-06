import 'dart:convert';
import 'dart:math' show sqrt, min;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/storage/secure_storage_service.dart';
import '../../../core/services/socket/socket_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/subscription_plan.dart';
import '../../../data/models/circle_dashboard.dart';

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
  final String id; // This is the user/receiver ID
  final RxnString roomId; // This is the chat room ID on the backend (nullable initially)
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
    String? initialRoomId,
    required this.name,
    required this.imageUrl,
    required String initialMessage,
    required String initialTime,
    bool unread = false,
    bool online = false,
    bool typing = false,
  })  : roomId = RxnString(initialRoomId),
        lastMessage = initialMessage.obs,
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

  // Active filter state
  final RxBool isFilterActive = false.obs;
  String? activeAgeGroup;
  int? activeMaxDistance;
  List<String> activeInterests  = [];
  List<String> activeLifestyle  = [];
  List<String> activeLanguages  = [];
  int? activeMinHeight;
  int? activeMaxHeight;
  bool? activeIsVerified;

  // Matches list & loading state
  final RxList<ProfileCardData> matches = <ProfileCardData>[].obs;
  final RxBool isLoadingMatches = false.obs;
  final List<ProfileCardData> likesYouList = [];

  // Messages list
  final RxList<ChatThread> chatThreads = <ChatThread>[].obs;
  final RxBool isLoadingChats = false.obs;
  final RxBool isLoadingMessages = false.obs;

  // Likes search list & loading state
  final RxList<Map<String, dynamic>> likedProfilesList = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingLikesSearch = false.obs;

  // Who Liked Me subscription state
  final RxBool hasWhoLikedMeSubscription = true.obs;
  final RxString selectedLikesFilter = 'all'.obs;
  final RxString whoLikedMeErrorMessage = ''.obs;

  // Subscription plans & active subscription observables
  final RxList<SubscriptionPlan> subscriptionPlans = <SubscriptionPlan>[].obs;
  final Rxn<UserSubscription> currentSubscription = Rxn<UserSubscription>();
  final RxBool isLoadingPlans = false.obs;
  final RxBool isSubmittingSubscription = false.obs;

  // Circle Events state
  final RxList<CircleEvent> circleEvents = <CircleEvent>[].obs;
  final RxBool isLoadingCircleEvents = false.obs;

  // Circle Discussions state
  final RxList<TrendingDiscussion> circleDiscussions = <TrendingDiscussion>[].obs;
  final RxBool isLoadingDiscussions = false.obs;
  final RxBool isSubmittingDiscussion = false.obs;

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
    fetchUserSubscription();
    fetchSubscriptionPlans();
    _loadInitialProfiles();
    _loadLikesYouList();
    _loadMatchesFromApi();
    loadWhoLikedMeProfiles();
    fetchCircleEvents();
    fetchCircleDiscussions();
    _initSocketService();
  }

  /// Fetch circle events from GET /api/circle/events
  Future<void> fetchCircleEvents() async {
    try {
      isLoadingCircleEvents.value = true;
      final authRepo = Get.find<AuthRepository>();
      final events = await authRepo.getCircleEvents();
      circleEvents.assignAll(events);
    } catch (e) {
      debugPrint('[HomeController] Error fetching circle events: $e');
    } finally {
      isLoadingCircleEvents.value = false;
    }
  }

  /// Fetch circle discussions from GET /api/circle/discussions
  Future<void> fetchCircleDiscussions() async {
    try {
      isLoadingDiscussions.value = true;
      final authRepo = Get.find<AuthRepository>();
      final discussions = await authRepo.getCircleDiscussions();
      circleDiscussions.assignAll(discussions);
    } catch (e) {
      debugPrint('[HomeController] Error fetching circle discussions: $e');
    } finally {
      isLoadingDiscussions.value = false;
    }
  }

  /// Create a circle discussion via POST /api/circle/discussions
  /// Automatically refreshes the discussions list on success.
  Future<void> createDiscussion({
    required String category,
    required String title,
    required String subtitle,
    bool isNewTag = false,
  }) async {
    try {
      isSubmittingDiscussion.value = true;
      final authRepo = Get.find<AuthRepository>();
      await authRepo.createDiscussion(
        category: category,
        title: title,
        subtitle: subtitle,
        isNewTag: isNewTag,
      );
      // Refresh the list after successful creation
      await fetchCircleDiscussions();
    } catch (e) {
      debugPrint('[HomeController] Error creating discussion: $e');
    } finally {
      isSubmittingDiscussion.value = false;
    }
  }

  /// Connect with a circle member — POST /api/circle/connect/:userId
  final RxBool isConnecting = false.obs;

  Future<void> connectWithMember(String userId) async {
    try {
      isConnecting.value = true;
      final authRepo = Get.find<AuthRepository>();
      final result = await authRepo.connectWithMember(userId);
      debugPrint('[HomeController] Connect with member result: $result');
      Get.snackbar(
        'Connection Sent',
        'Your connection request has been sent!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.gold,
        colorText: Colors.black,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('[HomeController] Error connecting with member: $e');
      Get.snackbar(
        'Error',
        'Failed to send connection request',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isConnecting.value = false;
    }
  }

  void _initSocketService() async {
    try {
      debugPrint('[HomeController] [Socket] Initializing SocketService...');
      final socketService = Get.find<SocketService>();
      await socketService.init();
      debugPrint('[HomeController] [Socket] SocketService init complete. Registering listeners...');

      // Listen for socket events
      // 4. receiveMessage
      ever(socketService.latestIncomingMessage, (data) {
        if (data != null) {
          debugPrint('[HomeController] [Socket] Reaction fired: latestIncomingMessage = $data');
          _handleIncomingSocketMessage(data);
        }
      });

      // 7. userStatusChanged
      ever(socketService.latestUserStatus, (data) {
        if (data != null) {
          debugPrint('[HomeController] [Socket] Reaction fired: latestUserStatus = $data');
          _handleSocketUserStatusChanged(data);
        }
      });

      // 2. getChats from socket
      isLoadingChats.value = true;
      socketService.getChats((chatsList) {
        isLoadingChats.value = false;
        debugPrint('[HomeController] [Socket] getChats callback received with ${chatsList.length} items');
        if (chatsList.isNotEmpty) {
          _populateChatsFromSocket(chatsList);
        }
      });

      // 5. getNewMatches from socket
      socketService.getNewMatches((matchesList) {
        debugPrint('[HomeController] [Socket] getNewMatches callback received with ${matchesList.length} items');
        if (matchesList.isNotEmpty) {
          _populateMatchesFromSocket(matchesList);
        }
      });
    } catch (e) {
      debugPrint('[HomeController] Error initializing SocketService: $e');
    }
  }

  Future<void> _loadInitialProfiles() async {
    try {
      isLoadingFeed.value = true;
      profiles.clear();
      final authRepo = Get.find<AuthRepository>();
      final feedList = await authRepo.getFeed();
      profiles.addAll(feedList.map(_mapToCard));
    } catch (e) {
      debugPrint('[HomeController] Error loading discovery feed: $e');
    } finally {
      isLoadingFeed.value = false;
    }
  }

  /// Applies the given filter params, calls POST /api/matches/filter,
  /// and replaces the profile deck with the results.
  Future<void> applyFilter({
    String? ageGroup,
    int? maxDistance,
    List<String> interests  = const [],
    List<String> lifestyle  = const [],
    List<String> languages  = const [],
    int? minHeight,
    int? maxHeight,
    bool? isVerified,
  }) async {
    try {
      isLoadingFeed.value = true;
      profiles.clear();

      // Store active filters
      activeAgeGroup    = ageGroup;
      activeMaxDistance = maxDistance;
      activeInterests   = interests;
      activeLifestyle   = lifestyle;
      activeLanguages   = languages;
      activeMinHeight   = minHeight;
      activeMaxHeight   = maxHeight;
      activeIsVerified  = isVerified;
      isFilterActive.value = true;

      final authRepo = Get.find<AuthRepository>();
      final filtered = await authRepo.filterFeed(
        ageGroup:     ageGroup,
        maxDistance:  maxDistance,
        interests:    interests.isNotEmpty   ? interests  : null,
        lifestyle:    lifestyle.isNotEmpty   ? lifestyle  : null,
        languages:    languages.isNotEmpty   ? languages  : null,
        minHeight:    minHeight,
        maxHeight:    maxHeight,
        isVerified:   isVerified,
      );
      profiles.addAll(filtered.map(_mapToCard));
    } catch (e) {
      debugPrint('[HomeController] Error applying filter: $e');
      Get.snackbar(
        'Filter Error',
        'Could not apply filters. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface,
        colorText: AppColors.textPrimary,
      );
    } finally {
      isLoadingFeed.value = false;
    }
  }

  /// Clears all active filters and reloads the default discovery feed.
  Future<void> clearFilter() async {
    activeAgeGroup    = null;
    activeMaxDistance = null;
    activeInterests   = [];
    activeLifestyle   = [];
    activeLanguages   = [];
    activeMinHeight   = null;
    activeMaxHeight   = null;
    activeIsVerified  = null;
    isFilterActive.value = false;
    await _loadInitialProfiles();
  }

  /// Maps a [UserProfile] from the API into a [ProfileCardData] for the card deck.
  ProfileCardData _mapToCard(UserProfile up) {
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
      job: up.jobTitle.isNotEmpty ? up.jobTitle : 'Professional',
      distance: up.distancePreference > 0 ? '${up.distancePreference} miles away' : 'Nearby',
      bio: up.bio.isNotEmpty ? up.bio : 'Hello! I\'m looking for real connections.',
      matchScore: '95',
      imageUrl: picUrl,
      isVerified: up.isVerified,
      location: up.livingIn.isNotEmpty ? up.livingIn : 'New Delhi',
      height: up.height.isNotEmpty ? '${up.height} cm' : '',
      education: up.school.isNotEmpty ? up.school : '',
      languages: up.languages.isNotEmpty ? up.languages.join(', ') : 'EN',
      interests: up.interests,
      lifestyle: up.lifestyle,
    );
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

  Future<void> loadWhoLikedMeProfiles() async {
    try {
      isLoadingLikesSearch.value = true;
      whoLikedMeErrorMessage.value = '';

      final authRepo = Get.find<AuthRepository>();
      final response = await authRepo.getWhoLikedMe(
        filter: selectedLikesFilter.value,
        page: 1,
        limit: 20,
      );

      debugPrint('[HomeController] getWhoLikedMe response: $response');

      if (response is Map<String, dynamic>) {
        if (response['success'] == false || response['statusCode'] == 403) {
          hasWhoLikedMeSubscription.value = false;
          whoLikedMeErrorMessage.value = response['message']?.toString() ?? 'Active subscription required to see who liked you';
          likedProfilesList.clear();
          return;
        }
      }

      // If we got here, subscription is active
      hasWhoLikedMeSubscription.value = true;
      final List<UserProfile> profiles = _parseUserProfileListResponse(response);
      likedProfilesList.assignAll(profiles.map(_mapUserProfileToLikedProfile).toList());
    } catch (e) {
      debugPrint('[HomeController] Error loading who liked me profiles: $e');
      final errStr = e.toString();
      
      if (errStr.contains('subscription') || errStr.contains('subscribed') || errStr.contains('403')) {
        hasWhoLikedMeSubscription.value = false;
        whoLikedMeErrorMessage.value = 'Active subscription required to see who liked you';
        likedProfilesList.clear();
      } else {
        hasWhoLikedMeSubscription.value = true;
        likedProfilesList.clear();
      }
    } finally {
      isLoadingLikesSearch.value = false;
    }
  }

  List<UserProfile> _parseUserProfileListResponse(dynamic json) {
    List<dynamic>? rawList;

    if (json is List) {
      rawList = json;
    } else if (json is Map<String, dynamic>) {
      // Try common wrapper keys in order of likelihood
      for (final key in ['users', 'profiles', 'feed', 'data', 'results']) {
        if (json.containsKey(key) && json[key] is List) {
          rawList = json[key] as List<dynamic>;
          break;
        }
      }
      // If still null, look for first list value in the map
      if (rawList == null) {
        for (final val in json.values) {
          if (val is List) {
            rawList = val;
            break;
          }
        }
      }
    } else if (json is String) {
      try {
        final decoded = jsonDecode(json);
        return _parseUserProfileListResponse(decoded);
      } catch (_) {}
    }

    if (rawList == null || rawList.isEmpty) return [];

    return rawList
        .whereType<Map<String, dynamic>>()
        .map((e) => UserProfile.fromJson(e))
        .toList();
  }

  Future<void> fetchSubscriptionPlans() async {
    try {
      isLoadingPlans.value = true;
      final authRepo = Get.find<AuthRepository>();
      final plans = await authRepo.getAllPlans();
      debugPrint('[HomeController] Loaded ${plans.length} subscription plans from API');
      subscriptionPlans.assignAll(plans);
    } catch (e) {
      debugPrint('[HomeController] Error loading subscription plans: $e');
    } finally {
      isLoadingPlans.value = false;
    }
  }

  Future<void> fetchUserSubscription() async {
    try {
      final authRepo = Get.find<AuthRepository>();
      final sub = await authRepo.getMySubscription();
      debugPrint('[HomeController] Loaded user subscription from API. Has Active: ${sub.hasActiveSubscription}');
      currentSubscription.value = sub;
      // Mirror subscription status to whoLikedMeSubscription
      if (sub.hasActiveSubscription && sub.isActive) {
        hasWhoLikedMeSubscription.value = true;
      }
    } catch (e) {
      debugPrint('[HomeController] Error loading user subscription: $e');
    }
  }

  Future<bool> purchaseSubscription(String planId, String billingCycle) async {
    try {
      isSubmittingSubscription.value = true;
      final authRepo = Get.find<AuthRepository>();
      final response = await authRepo.subscribe(
        planId: planId,
        billingCycle: billingCycle,
      );
      
      debugPrint('[HomeController] Purchase subscription response: $response');
      
      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Successfully subscribed to plan!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withOpacity(0.9),
          colorText: Colors.white,
        );
        // Refresh subscription state
        await fetchUserSubscription();
        // Refresh who liked me profiles list
        await loadWhoLikedMeProfiles();
        return true;
      } else {
        Get.snackbar(
          'Subscription Failed',
          response['message']?.toString() ?? 'Failed to subscribe. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.surface,
          colorText: AppColors.textPrimary,
        );
        return false;
      }
    } catch (e) {
      debugPrint('[HomeController] Error subscribing: $e');
      Get.snackbar(
        'Subscription Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface,
        colorText: AppColors.textPrimary,
      );
      return false;
    } finally {
      isSubmittingSubscription.value = false;
    }
  }

  Map<String, dynamic> _mapUserProfileToLikedProfile(UserProfile up) {
    String picUrl = up.profilePic;
    if (picUrl.isEmpty) {
      picUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=80';
    } else if (!picUrl.startsWith('http') && !picUrl.startsWith('assets/')) {
      picUrl = picUrl.startsWith('/')
          ? 'https://datingapp-oz22.onrender.com$picUrl'
          : 'https://datingapp-oz22.onrender.com/$picUrl';
    }
    return {
      'name': up.name,
      'age': up.age,
      'occupation': up.jobTitle.isNotEmpty ? up.jobTitle : 'Professional',
      'imageUrl': picUrl,
      'id': up.id,
    };
  }

  Future<void> searchLikedProfiles(String query) async {
    if (query.trim().isEmpty) {
      loadWhoLikedMeProfiles();
      return;
    }
    
    try {
      isLoadingLikesSearch.value = true;
      final authRepo = Get.find<AuthRepository>();
      final List<UserProfile> results = await authRepo.searchLikes(query);
      likedProfilesList.assignAll(results.map(_mapUserProfileToLikedProfile).toList());
    } catch (e) {
      debugPrint('[HomeController] Error searching likes: $e');
    } finally {
      isLoadingLikesSearch.value = false;
    }
  }

  /// Fetch real matches from the API and populate the matches list.
  Future<void> _loadMatchesFromApi() async {
    try {
      isLoadingMatches.value = true;
      matches.clear();
      final authRepo = Get.find<AuthRepository>();
      final matchList = await authRepo.getMatches();
      final mapped = matchList.map((up) {
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
          job: up.jobTitle.isNotEmpty ? up.jobTitle : 'Professional',
          distance: up.distancePreference > 0 ? '${up.distancePreference} miles away' : 'Nearby',
          bio: up.bio.isNotEmpty ? up.bio : 'Hello! Looking for a real connection.',
          matchScore: '95',
          imageUrl: picUrl,
          isVerified: up.isVerified,
          location: up.livingIn.isNotEmpty ? up.livingIn : 'Unknown',
          height: up.height.isNotEmpty ? '${up.height} cm' : '',
          education: up.school.isNotEmpty ? up.school : '',
          languages: up.languages.isNotEmpty ? up.languages.join(', ') : 'EN',
          interests: up.interests,
          lifestyle: up.lifestyle,
        );
      }).toList();
      matches.addAll(mapped);
    } catch (e) {
      debugPrint('[HomeController] Error loading matches from API: $e');
      // No dummy fallback — the UI already shows "No matches yet" when empty
    } finally {
      isLoadingMatches.value = false;
    }
  }


  void _loadMessagesFromSocket(ChatThread chat) {
    try {
      isLoadingMessages.value = true;
      final socketService = Get.find<SocketService>();
      final String fetchId = chat.roomId.value ?? chat.id;
      
      socketService.getMessages(
        chatId: fetchId,
        callback: (msgList) {
          isLoadingMessages.value = false;
          debugPrint('[HomeController] [Socket] getMessages returned ${msgList.length} items for chat ${chat.id} (roomId: ${chat.roomId.value})');
          
          final List<Map<String, dynamic>> parsedMessages = [];
          for (var m in msgList) {
            if (m is Map) {
              final String text = m['message']?.toString() ?? m['text']?.toString() ?? '';
              final String senderId = m['senderId']?.toString() ?? m['sender']?['_id']?.toString() ?? m['sender']?.toString() ?? '';
              final bool isMe = senderId == currentUserProfile.value?.id || m['sender'] == 'me';
              parsedMessages.add({
                'text': text,
                'sender': isMe ? 'me' : 'them',
                'time': m['time']?.toString() ?? _formatCurrentTime(),
                'date': m['date']?.toString() ?? 'TODAY',
              });
            }
          }
          chat.messages.assignAll(parsedMessages);
        },
      );
    } catch (e) {
      isLoadingMessages.value = false;
      debugPrint('[HomeController] Error loading messages from Socket: $e');
    }
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

    // Call the real API and check for a mutual match
    if (action == 'like') {
      _handleLikeAction(profile);
    } else if (action == 'super') {
      _handleSuperLikeAction(profile);
    } else if (action == 'nope') {
      _handlePassAction(profile);
    }
  }

  /// Sends the like to the backend. If it returns isMatch=true, show match dialog.
  void _handleLikeAction(ProfileCardData profile) async {
    try {
      final authRepo = Get.find<AuthRepository>();
      final result = await authRepo.likeUser(profile.id);
      final bool isMatch = result['isMatch'] == true ||
          result['match'] == true ||
          result['matched'] == true;
      if (isMatch) {
        _triggerMatchDialog(profile);
      }
    } catch (e) {
      debugPrint('[HomeController] Like API error for ${profile.id}: $e');
      // Silently fail — do not crash the swipe experience
    }
  }

  /// Sends the super-like to the backend.
  void _handleSuperLikeAction(ProfileCardData profile) async {
    try {
      final authRepo = Get.find<AuthRepository>();
      final result = await authRepo.superLikeUser(profile.id);
      final bool isMatch = result['isMatch'] == true ||
          result['match'] == true ||
          result['matched'] == true ||
          (result['swipe'] != null && result['swipe']['isMatch'] == true);
      if (isMatch) {
        _triggerMatchDialog(profile);
      }
    } catch (e) {
      debugPrint('[HomeController] Super Like API error for ${profile.id}: $e');
      // Silently fail — do not crash the swipe experience
    }
  }

  /// Sends pass (X) to the backend — POST /api/matches/pass
  void _handlePassAction(ProfileCardData profile) async {
    try {
      final authRepo = Get.find<AuthRepository>();
      await authRepo.passUser(profile.id);
    } catch (e) {
      debugPrint('[HomeController] Pass API error for ${profile.id}: $e');
      // Silently fail — do not crash the swipe experience
    }
  }

  void forceSwipe(String direction) {
    _executeSwipeAction(direction);
  }

  void undoSwipe() {
    if (swipeHistory.isEmpty) {
      // History is empty — ignore quietly to prevent continuous snackbars
      return;
    }

    final ProfileCardData restoredProfile = swipeHistory.removeLast();
    profiles.insert(0, restoredProfile);

    // Notify the backend — POST /api/matches/rewind { "targetUserId": id }
    _handleRewindAction(restoredProfile);
  }

  /// Sends rewind to the backend — POST /api/matches/rewind
  void _handleRewindAction(ProfileCardData profile) async {
    try {
      final authRepo = Get.find<AuthRepository>();
      await authRepo.rewindSwipe(profile.id);
    } catch (e) {
      debugPrint('[HomeController] Rewind API error for ${profile.id}: $e');
      // Silently fail — card is already restored locally
    }
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

  // --- Messaging Chat Detail View & Socket Handling ---

  void openChatDetail(ChatThread chat) {
    debugPrint('[HomeController] openChatDetail() called - chatId: "${chat.id}", name: "${chat.name}"');
    
    // Fetch latest messages via Socket
    _loadMessagesFromSocket(chat);

    // Fetch user status via Socket.IO
    try {
      final socketService = Get.find<SocketService>();
      debugPrint('[HomeController] [Socket] Requesting user status for targetUserId (chatId): "${chat.id}"');
      socketService.getUserStatus(
        targetUserId: chat.id,
        callback: (isOnline, lastSeen) {
          debugPrint('[HomeController] [Socket] getUserStatus callback for "${chat.id}": isOnline = $isOnline, lastSeen = $lastSeen');
          chat.isOnline.value = isOnline;
        },
      );
    } catch (e) {
      debugPrint('[HomeController] Error calling socket getUserStatus: $e');
    }

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

  void sendMessage(ChatThread chat) async {
    final text = chatInputController.text.trim();
    if (text.isEmpty) return;

    chatInputController.clear();
    
    debugPrint('[HomeController] [Socket] sendMessage() locally inserting message: "$text" for chat: "${chat.name}"');
    // Add my message locally
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

    // Send message via Socket
    try {
      final socketService = Get.find<SocketService>();
      debugPrint('[HomeController] [Socket] Dispatching sendMessage receiverId: "${chat.id}"');
      socketService.sendMessage(
        receiverId: chat.id,
        message: text,
        onAck: (response) {
          debugPrint('[HomeController] [Socket] sendMessage response: $response');
          if (response != null && response is Map && response['success'] == true) {
            final dataObj = response['data'];
            if (dataObj is Map && dataObj.containsKey('chat')) {
              final String newRoomId = dataObj['chat']?.toString() ?? '';
              if (newRoomId.isNotEmpty) {
                chat.roomId.value = newRoomId;
                debugPrint('[HomeController] [Socket] Resolved and stored roomId: "$newRoomId" for user: "${chat.name}"');
              }
            }
          }
        },
      );
    } catch (e) {
      debugPrint('[HomeController] Error sending Socket message: $e');
      Get.snackbar(
        'Send Error',
        'Failed to send message via socket. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.surface,
        colorText: AppColors.textPrimary,
      );
    }

    // Demo fallback for Elena
    if (chat.name.contains('Elena')) {
      _simulateReply(chat, text);
    }
  }

  void _handleIncomingSocketMessage(Map<String, dynamic> data) {
    debugPrint('[HomeController] [Socket] _handleIncomingSocketMessage() - Raw payload: $data');
    final String senderId = data['senderId']?.toString() ??
        data['sender']?['_id']?.toString() ??
        data['sender']?.toString() ??
        '';
    final String chatId = data['chatId']?.toString() ?? data['chat']?.toString() ?? '';
    final String text = data['message']?.toString() ?? data['text']?.toString() ?? '';
    final String time = _formatCurrentTime();

    if (text.isEmpty) {
      debugPrint('[HomeController] [Socket] Warning: Received empty message text. Skipping.');
      return;
    }

    ChatThread? chat = chatThreads.firstWhereOrNull(
      (c) => c.id == senderId || (chatId.isNotEmpty && c.roomId.value == chatId)
    );
    
    if (chat != null) {
      debugPrint('[HomeController] [Socket] Appending incoming message to existing chat thread (id: "${chat.id}", name: "${chat.name}")');
      if (chatId.isNotEmpty && chat.roomId.value == null) {
        chat.roomId.value = chatId;
      }
      chat.messages.add({
        'text': text,
        'sender': 'them',
        'time': time,
        'date': 'TODAY',
      });
      chat.lastMessage.value = text;
      chat.time.value = time;
      chat.isUnread.value = true;
    } else {
      final String name = data['senderName']?.toString() ?? data['sender']?['name']?.toString() ?? 'New Message';
      final String photo = data['senderPhoto']?.toString() ?? data['sender']?['profilePic']?.toString() ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=80';
      debugPrint('[HomeController] [Socket] Chat thread not found for senderId: "$senderId". Creating new ChatThread (name: "$name", roomId: "$chatId")');
      final newChat = ChatThread(
        id: senderId.isNotEmpty ? senderId : DateTime.now().millisecondsSinceEpoch.toString(),
        initialRoomId: chatId.isNotEmpty ? chatId : null,
        name: name,
        imageUrl: photo.startsWith('http') ? photo : 'https://datingapp-oz22.onrender.com/$photo',
        initialMessage: text,
        initialTime: time,
        unread: true,
        online: true,
      );
      chatThreads.insert(0, newChat);
    }
  }

  void _handleSocketUserStatusChanged(Map<String, dynamic> data) {
    debugPrint('[HomeController] [Socket] _handleSocketUserStatusChanged() - Raw payload: $data');
    final String targetUserId = data['userId']?.toString() ?? data['targetUserId']?.toString() ?? '';
    final bool isOnline = data['isOnline'] == true;
    if (targetUserId.isNotEmpty) {
      final chat = chatThreads.firstWhereOrNull((c) => c.id == targetUserId);
      if (chat != null) {
        debugPrint('[HomeController] [Socket] Updating online status for chat (id: "${chat.id}", name: "${chat.name}") -> isOnline: $isOnline');
        chat.isOnline.value = isOnline;
      } else {
        debugPrint('[HomeController] [Socket] No matching chat thread found for targetUserId: "$targetUserId" to update status');
      }
    } else {
      debugPrint('[HomeController] [Socket] Warning: targetUserId is empty in userStatusChanged payload');
    }
  }

  void _populateChatsFromSocket(List<dynamic> chatsList) {
    debugPrint('[HomeController] [Socket] _populateChatsFromSocket() called with ${chatsList.length} items');
    for (var item in chatsList) {
      if (item is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final String chatId = map['_id']?.toString() ?? map['chatId']?.toString() ?? map['id']?.toString() ?? '';
        final userObj = map['user'] ?? map['participant'] ?? map['receiver'] ?? {};
        final String name = userObj['name']?.toString() ?? map['name']?.toString() ?? 'Connection';
        final String photo = userObj['profilePic']?.toString() ?? map['imageUrl']?.toString() ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=80';
        final lastMsgObj = map['lastMessage'];
        final String lastMsgText = lastMsgObj is Map ? (lastMsgObj['message'] ?? lastMsgObj['text'] ?? '') : (lastMsgObj?.toString() ?? 'No messages yet');
        final bool isOnline = userObj['isOnline'] == true || map['isOnline'] == true;
        final String userObjId = userObj['_id']?.toString() ?? '';

        final existing = chatThreads.firstWhereOrNull(
          (c) => (userObjId.isNotEmpty && c.id == userObjId) || (chatId.isNotEmpty && c.roomId.value == chatId)
        );
        
        if (existing != null) {
          debugPrint('[HomeController] [Socket] Chat thread already exists (id: "${existing.id}", name: "${existing.name}"). Updating last message, status, and roomId.');
          if (chatId.isNotEmpty && existing.roomId.value == null) {
            existing.roomId.value = chatId;
          }
          existing.lastMessage.value = lastMsgText;
          existing.isOnline.value = isOnline;
        } else {
          final String targetUserId = userObjId.isNotEmpty ? userObjId : (chatId.isNotEmpty ? chatId : DateTime.now().millisecondsSinceEpoch.toString());
          debugPrint('[HomeController] [Socket] Creating new chat thread from populate (id: "$targetUserId", roomId: "$chatId", name: "$name")');
          final newChat = ChatThread(
            id: targetUserId,
            initialRoomId: chatId.isNotEmpty ? chatId : null,
            name: name,
            imageUrl: photo.startsWith('http') ? photo : 'https://datingapp-oz22.onrender.com/$photo',
            initialMessage: lastMsgText,
            initialTime: 'Recent',
            online: isOnline,
          );
          chatThreads.add(newChat);
        }
      }
    }
  }

  void _populateMatchesFromSocket(List<dynamic> matchesList) {
    debugPrint('[HomeController] [Socket] _populateMatchesFromSocket() called with ${matchesList.length} items');
    for (var item in matchesList) {
      if (item is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final String id = map['_id']?.toString() ?? map['id']?.toString() ?? '';
        final String name = map['name']?.toString() ?? 'Match';
        final int age = map['age'] is int ? map['age'] : (int.tryParse(map['age']?.toString() ?? '25') ?? 25);
        String picUrl = map['profilePic']?.toString() ?? '';
        if (picUrl.isEmpty) {
          picUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&auto=format&fit=crop&q=80';
        } else if (!picUrl.startsWith('http') && !picUrl.startsWith('assets/')) {
          picUrl = 'https://datingapp-oz22.onrender.com/$picUrl';
        }

        final existing = matches.firstWhereOrNull((m) => m.id == id);
        if (existing == null && id.isNotEmpty) {
          debugPrint('[HomeController] [Socket] Adding new match from populate (id: "$id", name: "$name")');
          matches.add(ProfileCardData(
            id: id,
            name: name,
            age: age,
            job: map['jobTitle']?.toString() ?? 'Professional',
            distance: 'Nearby',
            bio: map['bio']?.toString() ?? '',
            matchScore: '95',
            imageUrl: picUrl,
            location: map['livingIn']?.toString() ?? '',
            height: map['height']?.toString() ?? '',
            education: map['school']?.toString() ?? '',
            languages: 'EN',
            interests: [],
            lifestyle: [],
          ));
        } else {
          debugPrint('[HomeController] [Socket] Match already exists or id is empty (id: "$id", name: "$name"). Skipping.');
        }
      }
    }
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
