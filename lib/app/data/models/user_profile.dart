import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String gender;
  final String interestedIn;
  final int age;
  final String bio;
  final String jobTitle;
  final String company;
  final String school;
  final String livingIn;
  final String height;
  final double longitude;
  final double latitude;
  final int distancePreference;
  final List<String> interests;
  final String profilePic;
  final List<String> additionalPhotos;
  final bool isVerified;
  final List<String> languages;
  final List<String> lifestyle;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.gender,
    required this.interestedIn,
    required this.age,
    required this.bio,
    required this.jobTitle,
    required this.company,
    required this.school,
    required this.livingIn,
    required this.height,
    required this.longitude,
    required this.latitude,
    required this.distancePreference,
    required this.interests,
    required this.profilePic,
    required this.additionalPhotos,
    required this.isVerified,
    required this.languages,
    required this.lifestyle,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final data = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : json;

    // Parse interests safely
    List<String> parseInterests(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        try {
          final decoded = jsonDecode(value);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      } else if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    // Parse additionalPhotos safely
    List<String> parsePhotos(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    List<String> parseLanguages(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    List<String> parseLifestyle(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      return [];
    }

    int parseAge(dynamic val) {
      if (val == null) return 29;
      if (val is int) return val;
      if (val is String) {
        return int.tryParse(val) ?? 29;
      }
      return 29;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) {
        return double.tryParse(val) ?? 0.0;
      }
      return 0.0;
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is String) {
        return int.tryParse(val) ?? 0;
      }
      return 0;
    }

    return UserProfile(
      id: data['_id'] as String? ?? data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      interestedIn: data['interestedIn'] as String? ?? '',
      age: parseAge(data['age']),
      bio: data['bio'] as String? ?? '',
      jobTitle: data['jobTitle'] as String? ?? '',
      company: data['company'] as String? ?? '',
      school: data['school'] as String? ?? '',
      livingIn: data['livingIn'] as String? ?? '',
      height: (data['height'] ?? '').toString(),
      longitude: parseDouble(data['longitude']),
      latitude: parseDouble(data['latitude']),
      distancePreference: parseInt(data['distancePreference']),
      interests: parseInterests(data['interests']),
      profilePic: data['profilePic'] as String? ?? '',
      additionalPhotos: parsePhotos(data['additionalPhotos']),
      isVerified: data['isVerified'] as bool? ?? false,
      languages: parseLanguages(data['languages']),
      lifestyle: parseLifestyle(data['lifestyle']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'gender': gender,
      'interestedIn': interestedIn,
      'age': age,
      'bio': bio,
      'jobTitle': jobTitle,
      'company': company,
      'school': school,
      'livingIn': livingIn,
      'height': height,
      'longitude': longitude,
      'latitude': latitude,
      'distancePreference': distancePreference,
      'interests': interests,
      'profilePic': profilePic,
      'additionalPhotos': additionalPhotos,
      'isVerified': isVerified,
      'languages': languages,
      'lifestyle': lifestyle,
    };
  }
}
