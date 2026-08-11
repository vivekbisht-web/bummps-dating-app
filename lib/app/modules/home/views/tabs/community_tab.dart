import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/bummps_logo.dart';
import '../../../../data/models/circle_dashboard.dart';
import '../../controllers/home_controller.dart';

class CommunityTab extends GetView<HomeController> {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const BummpsLogo(compact: true),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Sub-Tab Selector Header ---
            _buildSubTabHeader(context),
            
            // --- Active Sub-Tab View Content ---
            Expanded(
              child: Obx(() {
                switch (controller.circleSubTab.value) {
                  case 0:
                    return _buildDashboardView(context);
                  case 1:
                    return _buildDiscussionsView(context);
                  case 2:
                    return _buildEventsView(context);
                  default:
                    return _buildDashboardView(context);
                }
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(() {
        if (controller.circleSubTab.value == 1) {
          return FloatingActionButton.extended(
            onPressed: () => _showCreateDiscussionBottomSheet(context),
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.onGold,
            icon: const Icon(Icons.add, color: Colors.black),
            label: const Text(
              'NEW TOPIC',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-Tab Header Bar: Dashboard | Discussions | Events
  // ---------------------------------------------------------------------------
  Widget _buildSubTabHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Obx(() {
        return Row(
          children: [
            _buildTabSegment(0, 'Dashboard', Icons.dashboard_outlined),
            _buildTabSegment(1, 'Discussions', Icons.forum_outlined),
            _buildTabSegment(2, 'Events', Icons.event_outlined),
          ],
        );
      }),
    );
  }

  Widget _buildTabSegment(int index, String label, IconData icon) {
    final bool isSelected = controller.circleSubTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.circleSubTab.value = index,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.black : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SCREEN 1: Dashboard View
  // ---------------------------------------------------------------------------
  Widget _buildDashboardView(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      onRefresh: () async {
        await Future.wait([
          controller.fetchCircleDashboard(),
          controller.fetchCircleEvents(),
          controller.fetchCircleDiscussions(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Text(
              'The Bummps Circle',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.gold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Curated connections for the world\'s most discerning minds. Explore exclusive events and engage in high-fidelity conversations.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            // Top 5 Events Slider Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOP 5 EXCLUSIVE EVENTS',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                GestureDetector(
                  onTap: () => controller.circleSubTab.value = 2, // Switch to Events
                  child: Text(
                    'View All',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTop5EventsSlider(),
            const SizedBox(height: 28),

            // Featured Spotlight Member Section
            Row(
              children: [
                const Icon(Icons.star_outline, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Text(
                  'FEATURED SPOTLIGHT MEMBER',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMemberSpotlightCard(context),
            const SizedBox(height: 28),

            // Top 3 Trending Discussions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.gold, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'TOP 3 TRENDING DISCUSSIONS',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => controller.circleSubTab.value = 1, // Switch to Discussions
                  child: Text(
                    'See All',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTop3DiscussionsList(),
            const SizedBox(height: 28),

            // Members Online Counter Section
            _buildOnlineCounterBanner(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // --- Top 5 Events Slider ---
  Widget _buildTop5EventsSlider() {
    return Obx(() {
      final dashboard = controller.circleDashboard.value;
      List<CircleEvent> events = dashboard?.events ?? [];
      if (events.isEmpty) {
        events = controller.circleEvents;
      }
      final top5Events = events.take(5).toList();

      if (controller.isLoadingDashboard.value || controller.isLoadingCircleEvents.value) {
        return Container(
          height: 170,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(color: AppColors.gold),
        );
      }

      if (top5Events.isEmpty) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Center(
            child: Text(
              'No upcoming events right now',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),
        );
      }

      return SizedBox(
        height: 170,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: top5Events.length,
          itemBuilder: (context, index) {
            final event = top5Events[index];
            return _buildEventSliderCard(event);
          },
        ),
      );
    });
  }

  Widget _buildEventSliderCard(CircleEvent event) {
    String picUrl = event.image;
    if (picUrl.isEmpty) {
      picUrl = 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=600&auto=format&fit=crop&q=80';
    } else if (!picUrl.startsWith('http')) {
      picUrl = 'https://datingapp-oz22.onrender.com/$picUrl';
    }

    return Container(
      width: 230,
      margin: const EdgeInsets.only(right: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                picUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surface,
                  child: const Icon(Icons.event, color: AppColors.gold, size: 40),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            if (event.isExclusive)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'EXCLUSIVE',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 12,
              bottom: 44,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  event.dateText.isNotEmpty ? event.dateText : 'Upcoming',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Featured Member Spotlight ---
  Widget _buildMemberSpotlightCard(BuildContext context) {
    return Obx(() {
      final dashboard = controller.circleDashboard.value;
      final spotlight = dashboard?.memberSpotlight;

      final String name = (spotlight != null && spotlight.name.isNotEmpty)
          ? spotlight.name
          : 'Elena Vance';
      final String role = (spotlight != null && spotlight.role.isNotEmpty)
          ? spotlight.role
          : 'ARCHITECTURE LEAD | PARIS';
      final String quote = (spotlight != null && spotlight.quote.isNotEmpty)
          ? spotlight.quote
          : '"Seeking harmony between urban structure and human connection."';
      final String status = (spotlight != null && spotlight.status.isNotEmpty)
          ? spotlight.status
          : 'Premium';
      final int matchesCount = spotlight?.matchesCount ?? 42;
      final int eventsCount = spotlight?.eventsCount ?? 8;
      final String targetUserId = (spotlight != null && spotlight.id.isNotEmpty)
          ? spotlight.id
          : '65f123456789abcdef123456';

      String photoUrl = spotlight?.profilePic ?? '';
      if (photoUrl.isEmpty) {
        photoUrl = 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80';
      } else if (!photoUrl.startsWith('http')) {
        photoUrl = 'https://datingapp-oz22.onrender.com/$photoUrl';
      }

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gold, width: 1.5),
        ),
        child: Column(
          children: [
            // Profile Photo with Verified Badge
            Stack(
              children: [
                Container(
                  width: 86,
                  height: 86,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                  ),
                  padding: const EdgeInsets.all(2.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(43),
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.black,
                        child: const Icon(Icons.person, color: AppColors.gold, size: 40),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.verified,
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Member Name
            Text(
              name,
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Role / Job
            Text(
              role.toUpperCase(),
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 20),

            // Profile Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSpotlightStat('$matchesCount', 'MATCHES'),
                _buildSpotlightStat('$eventsCount', 'EVENTS'),
                _buildSpotlightStat(status, 'STATUS', isStatus: true),
              ],
            ),
            const SizedBox(height: 20),

            // Quote
            Text(
              quote.startsWith('"') ? quote : '"$quote"',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),

            // Connect Button (Triggers POST /api/circle/connect/:targetUserId)
            Obx(() => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.onGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: controller.isConnecting.value
                  ? null
                  : () {
                      controller.connectWithMember(
                        targetUserId,
                        spotlight: spotlight,
                      );
                    },
              child: controller.isConnecting.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      'CONNECT WITH ${name.split(' ').first.toUpperCase()}',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            )),
          ],
        ),
      );
    });
  }

  // --- Top 3 Trending Discussions ---
  Widget _buildTop3DiscussionsList() {
    return Obx(() {
      final dashboard = controller.circleDashboard.value;
      List<TrendingDiscussion> discussions = dashboard?.trendingDiscussions ?? [];
      if (discussions.isEmpty) {
        discussions = controller.circleDiscussions;
      }
      final top3Discussions = discussions.take(3).toList();

      if (controller.isLoadingDashboard.value || controller.isLoadingDiscussions.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
        );
      }

      if (top3Discussions.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          alignment: Alignment.center,
          child: Text(
            'No discussions posted yet',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        );
      }

      return Column(
        children: top3Discussions.map((discussion) {
          return _buildDiscussionCardItem(discussion);
        }).toList(),
      );
    });
  }

  // --- Members Online Counter Banner ---
  Widget _buildOnlineCounterBanner() {
    return Obx(() {
      final count = controller.circleDashboard.value?.onlineCircleCount ?? 1204;
      final digitsStr = count.toString().padLeft(4, '0');

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                Text(
                  'ONLINE CIRCLE MEMBERS',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Row(
              children: digitsStr.split('').map(_buildDigitBox).toList(),
            ),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // SCREEN 2: Discussions List View
  // ---------------------------------------------------------------------------
  Widget _buildDiscussionsView(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      onRefresh: () => controller.fetchCircleDiscussions(),
      child: Obx(() {
        if (controller.isLoadingDiscussions.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }

        if (controller.circleDiscussions.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.forum_outlined, color: AppColors.gold, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No Discussions Found',
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to start a conversation with the community!',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showCreateDiscussionBottomSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('CREATE TOPIC', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: controller.circleDiscussions.length,
          itemBuilder: (context, index) {
            final discussion = controller.circleDiscussions[index];
            return _buildDiscussionCardItem(discussion);
          },
        );
      }),
    );
  }

  // --- Discussion Card Item with Poster Details ---
  Widget _buildDiscussionCardItem(TrendingDiscussion discussion) {
    final creatorName = discussion.createdBy.name.isNotEmpty
        ? discussion.createdBy.name
        : 'Circle Member';

    String avatarUrl = discussion.createdBy.profilePic;
    if (avatarUrl.isEmpty) {
      avatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80';
    } else if (!avatarUrl.startsWith('http')) {
      avatarUrl = 'https://datingapp-oz22.onrender.com/$avatarUrl';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Header Row
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.gold,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  creatorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  discussion.category.isNotEmpty ? discussion.category : 'General',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (discussion.isNewTag) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.gold, width: 1.0),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Discussion Title
          Text(
            discussion.title,
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            discussion.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),

          // Footer Row
          Row(
            children: [
              const Icon(Icons.forum_outlined, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(
                '${discussion.repliesCount} replies',
                style: AppTextStyles.caption.copyWith(fontSize: 11),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: AppColors.textMuted, size: 14),
              const SizedBox(width: 4),
              Text(
                _timeAgo(discussion.createdAt),
                style: AppTextStyles.caption.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SCREEN 3: Create Discussion Form (Modal Bottom Sheet)
  // ---------------------------------------------------------------------------
  void _showCreateDiscussionBottomSheet(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final selectedCategory = 'Tech & Startup'.obs;

    final categories = [
      'Tech & Startup',
      'Lifestyle',
      'Events & Parties',
      'Networking',
      'Career',
      'Travel',
    ];

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Indicator Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Create New Discussion',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Share your thoughts with the Bummps Circle community.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),

              // Category selector label
              Text(
                'CATEGORY',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = selectedCategory.value == cat;
                  return ChoiceChip(
                    label: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.gold,
                    backgroundColor: const Color(0xFF1C1C20),
                    onSelected: (selected) {
                      if (selected) selectedCategory.value = cat;
                    },
                  );
                }).toList(),
              )),
              const SizedBox(height: 18),

              // Title Field
              Text(
                'TOPIC TITLE',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Best places to co-work in Paris?',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF1C1C20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gold),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Subtitle Field
              Text(
                'SUBTITLE / DESCRIPTION',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: subtitleController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g. Looking for quiet cafes with good WiFi and coffee.',
                  hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF1C1C20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gold),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit / Publish Button
              Obx(() => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: controller.isSubmittingDiscussion.value
                    ? null
                    : () {
                        final title = titleController.text.trim();
                        final subtitle = subtitleController.text.trim();
                        if (title.isEmpty) {
                          AppSnackbar.showError(
                            title: 'Title Required',
                            message: 'Please enter a topic title.',
                          );
                          return;
                        }
                        controller.createDiscussion(
                          category: selectedCategory.value,
                          title: title,
                          subtitle: subtitle,
                          isNewTag: true,
                        );
                      },
                child: controller.isSubmittingDiscussion.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'PUBLISH DISCUSSION',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              )),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ---------------------------------------------------------------------------
  // SCREEN 4: Events List View
  // ---------------------------------------------------------------------------
  Widget _buildEventsView(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      onRefresh: () => controller.fetchCircleEvents(),
      child: Obx(() {
        if (controller.isLoadingCircleEvents.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }

        if (controller.circleEvents.isEmpty) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Icon(Icons.event_busy_outlined, color: AppColors.gold, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No Upcoming Events',
                    style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back soon for exclusive gathering announcements.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: controller.circleEvents.length,
          itemBuilder: (context, index) {
            final event = controller.circleEvents[index];
            return _buildFullEventCard(event);
          },
        );
      }),
    );
  }

  Widget _buildFullEventCard(CircleEvent event) {
    String picUrl = event.image;
    if (picUrl.isEmpty) {
      picUrl = 'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&auto=format&fit=crop&q=80';
    } else if (!picUrl.startsWith('http')) {
      picUrl = 'https://datingapp-oz22.onrender.com/$picUrl';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Image Banner
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Image.network(
                    picUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surface,
                      child: const Icon(Icons.event, color: AppColors.gold, size: 48),
                    ),
                  ),
                ),
              ),
              if (event.isExclusive)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'EXCLUSIVE',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Event Content Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Location Badges
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.gold, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      event.dateText.isNotEmpty ? event.dateText : 'TBA',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        event.location.isNotEmpty ? event.location : 'Paris, France',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Event Title
                Text(
                  event.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets & Utils ---
  Widget _buildSpotlightStat(String value, String label, {bool isStatus = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isStatus ? 15 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDigitBox(String digit) {
    return Container(
      width: 20,
      height: 26,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF222228),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
