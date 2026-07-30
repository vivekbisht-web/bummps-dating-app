import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Image.asset(
            'assets/images/bummps-icon.png',
            fit: BoxFit.contain,
          ),
        ),
        leadingWidth: 48,
        title: Image.asset(
          'assets/images/bummps..png',
          height: 18,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Section ---
              Text(
                'The Bummps Circle',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Curated connections for the world\'s most discerning minds. Explore exclusive events and engage in high-fidelity conversations.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),

              // --- Exclusive Events Section ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EXCLUSIVE EVENTS',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'View Calendar',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 170,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildEventCard(
                      title: 'Gala Night in Paris',
                      date: 'OCT 24',
                      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=600&auto=format&fit=crop&q=80',
                    ),
                    _buildEventCard(
                      title: 'Private Vineyard tasting',
                      date: 'NOV 12',
                      imageUrl: 'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?w=600&auto=format&fit=crop&q=80',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- Trending Discussions Section ---
              Row(
                children: [
                  const Icon(Icons.trending_up, color: AppColors.gold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'TRENDING DISCUSSIONS',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildDiscussionCard(
                category: 'PHILOSOPHY',
                isNew: true,
                title: 'The Art of Conversation',
                subtitle: 'Exploring the nuance of non-verbal cues',
                repliesCount: 128,
                timeAgo: '2h ago',
              ),
              _buildDiscussionCard(
                category: 'LIFESTYLE',
                title: 'Travel Destinations for Two',
                subtitle: 'Hidden gems from the Amalfi Coast to...',
                repliesCount: 84,
                timeAgo: '5h ago',
              ),
              _buildDiscussionCard(
                category: 'COLLECTIBLES',
                title: 'Vintage Horology Insights',
                subtitle: 'Why independent watchmakers are...',
                repliesCount: 210,
                timeAgo: '1d ago',
              ),
              const SizedBox(height: 28),

              // --- Member Spotlight Section ---
              Row(
                children: [
                  const Icon(Icons.star_outline, color: AppColors.gold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'MEMBER SPOTLIGHT',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: Column(
                  children: [
                    // Avatar stack
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
                              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Verified badge bottom-right
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

                    // Name
                    Text(
                      'Elena Vance',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      'ARCHITECTURE LEAD | PARIS',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Profile Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSpotlightStat('42', 'MATCHES'),
                        _buildSpotlightStat('8', 'EVENTS'),
                        _buildSpotlightStat('Premium', 'STATUS', isStatus: true),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description quote
                    Text(
                      '"Seeking harmony between urban structure and human connection."',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // CONNECT button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.onGold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () {},
                      child: Text(
                        'CONNECT WITH ELENA',
                        style: AppTextStyles.button.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // --- Online Circle Section ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ONLINE CIRCLE',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontSize: 11,
                      ),
                    ),
                    Row(
                      children: [
                        _buildDigitBox('1'),
                        const SizedBox(width: 4),
                        _buildDigitBox('2'),
                        const SizedBox(width: 4),
                        _buildDigitBox('0'),
                        const SizedBox(width: 4),
                        _buildDigitBox('4'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required String date,
    required String imageUrl,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),

            // Black scrim overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    stops: const [0.55, 1.0],
                  ),
                ),
              ),
            ),

            // Date tag
            Positioned(
              left: 12,
              bottom: 48,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Event Title
            Positioned(
              left: 12,
              bottom: 14,
              right: 12,
              child: Text(
                title,
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

  Widget _buildDiscussionCard({
    required String category,
    bool isNew = false,
    required String title,
    required String subtitle,
    required int repliesCount,
    required String timeAgo,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(Icons.forum_outlined, color: AppColors.textMuted, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$repliesCount replies',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, color: AppColors.textMuted, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      timeAgo,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

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
}
