/// Models for GET /api/circle/dashboard response.

// ---------------------------------------------------------------------------
// CircleEvent
// ---------------------------------------------------------------------------
class CircleEvent {
  final String id;
  final String title;
  final String dateText;
  final DateTime eventDate;
  final String location;
  final String image;
  final bool isExclusive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CircleEvent({
    required this.id,
    required this.title,
    required this.dateText,
    required this.eventDate,
    required this.location,
    required this.image,
    required this.isExclusive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CircleEvent.fromJson(Map<String, dynamic> json) {
    return CircleEvent(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      dateText: json['dateText'] as String? ?? '',
      eventDate: DateTime.tryParse(json['eventDate'] as String? ?? '') ??
          DateTime.now(),
      location: json['location'] as String? ?? '',
      image: json['image'] as String? ?? '',
      isExclusive: json['isExclusive'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'dateText': dateText,
        'eventDate': eventDate.toIso8601String(),
        'location': location,
        'image': image,
        'isExclusive': isExclusive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

// ---------------------------------------------------------------------------
// DiscussionCreator  (populated createdBy object)
// ---------------------------------------------------------------------------
class DiscussionCreator {
  final String id;
  final String name;
  final String profilePic;

  const DiscussionCreator({
    required this.id,
    required this.name,
    required this.profilePic,
  });

  factory DiscussionCreator.fromJson(Map<String, dynamic> json) {
    return DiscussionCreator(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profilePic: json['profilePic'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'profilePic': profilePic,
      };
}

// ---------------------------------------------------------------------------
// TrendingDiscussion
// ---------------------------------------------------------------------------
class TrendingDiscussion {
  final String id;
  final String category;
  final bool isNewTag;
  final String title;
  final String subtitle;
  final int repliesCount;
  final DiscussionCreator createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TrendingDiscussion({
    required this.id,
    required this.category,
    required this.isNewTag,
    required this.title,
    required this.subtitle,
    required this.repliesCount,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TrendingDiscussion.fromJson(Map<String, dynamic> json) {
    // createdBy can be a String (POST response) or a Map (GET populated response)
    final createdByRaw = json['createdBy'];
    DiscussionCreator creator;
    if (createdByRaw is Map<String, dynamic>) {
      creator = DiscussionCreator.fromJson(createdByRaw);
    } else {
      creator = DiscussionCreator(
        id: createdByRaw as String? ?? '',
        name: '',
        profilePic: '',
      );
    }

    return TrendingDiscussion(
      id: json['_id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      isNewTag: json['isNewTag'] as bool? ?? false,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      repliesCount: json['repliesCount'] as int? ?? 0,
      createdBy: creator,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'category': category,
        'isNewTag': isNewTag,
        'title': title,
        'subtitle': subtitle,
        'repliesCount': repliesCount,
        'createdBy': createdBy.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

// ---------------------------------------------------------------------------
// MemberSpotlight
// ---------------------------------------------------------------------------
class MemberSpotlight {
  final String id;
  final String name;
  final String role;
  final int matchesCount;
  final int eventsCount;
  final String status;
  final String quote;
  final String profilePic;

  const MemberSpotlight({
    required this.id,
    required this.name,
    required this.role,
    required this.matchesCount,
    required this.eventsCount,
    required this.status,
    required this.quote,
    required this.profilePic,
  });

  factory MemberSpotlight.fromJson(Map<String, dynamic> json) {
    return MemberSpotlight(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      matchesCount: json['matchesCount'] as int? ?? 0,
      eventsCount: json['eventsCount'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      quote: json['quote'] as String? ?? '',
      profilePic: json['profilePic'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'role': role,
        'matchesCount': matchesCount,
        'eventsCount': eventsCount,
        'status': status,
        'quote': quote,
        'profilePic': profilePic,
      };
}

// ---------------------------------------------------------------------------
// CircleDashboard  (top-level data object)
// ---------------------------------------------------------------------------
class CircleDashboard {
  final List<CircleEvent> events;
  final List<TrendingDiscussion> trendingDiscussions;
  final MemberSpotlight memberSpotlight;
  final int onlineCircleCount;

  const CircleDashboard({
    required this.events,
    required this.trendingDiscussions,
    required this.memberSpotlight,
    required this.onlineCircleCount,
  });

  factory CircleDashboard.fromJson(Map<String, dynamic> json) {
    final eventsJson = json['events'];
    final discussionsJson = json['trendingDiscussions'];
    final spotlightJson = json['memberSpotlight'];

    return CircleDashboard(
      events: (eventsJson is List)
          ? eventsJson
              .whereType<Map<String, dynamic>>()
              .map(CircleEvent.fromJson)
              .toList()
          : [],
      trendingDiscussions: (discussionsJson is List)
          ? discussionsJson
              .whereType<Map<String, dynamic>>()
              .map(TrendingDiscussion.fromJson)
              .toList()
          : [],
      memberSpotlight: spotlightJson is Map<String, dynamic>
          ? MemberSpotlight.fromJson(spotlightJson)
          : MemberSpotlight(
              id: '',
              name: '',
              role: '',
              matchesCount: 0,
              eventsCount: 0,
              status: '',
              quote: '',
              profilePic: '',
            ),
      onlineCircleCount: json['onlineCircleCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'events': events.map((e) => e.toJson()).toList(),
        'trendingDiscussions':
            trendingDiscussions.map((d) => d.toJson()).toList(),
        'memberSpotlight': memberSpotlight.toJson(),
        'onlineCircleCount': onlineCircleCount,
      };
}
