import 'package:cloud_firestore/cloud_firestore.dart';

/// Lightweight visitor summary stored on an online café session.
class OnlineCafeVisitorSummary {
  const OnlineCafeVisitorSummary({
    required this.profileId,
    required this.profileName,
    required this.shopTitle,
    required this.joinedAt,
  });

  final String profileId;
  final String profileName;
  final String shopTitle;
  final DateTime joinedAt;

  Map<String, dynamic> toMap() {
    return {
      'profileId': profileId,
      'profileName': profileName,
      'shopTitle': shopTitle,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  factory OnlineCafeVisitorSummary.fromMap(Map<String, dynamic> map) {
    return OnlineCafeVisitorSummary(
      profileId: OnlineCafeSession._readString(map, 'profileId') ?? 'visitor',
      profileName:
          OnlineCafeSession._readString(map, 'profileName') ?? 'Guest',
      shopTitle:
          OnlineCafeSession._readString(map, 'shopTitle') ?? 'Guest\'s Shop',
      joinedAt: OnlineCafeSession._readDateTime(map['joinedAt']),
    );
  }
}

/// Temporary online café session hosted in Firestore (v0.1.61+).
class OnlineCafeSession {
  const OnlineCafeSession({
    required this.sessionId,
    required this.joinCode,
    required this.hostProfileId,
    required this.hostProfileName,
    required this.hostShopName,
    required this.hostCharacter,
    required this.createdAt,
    required this.updatedAt,
    required this.isOpen,
    required this.visitorCount,
    required this.visitorSummaries,
    this.isLocalFallback = false,
  });

  final String sessionId;
  final String joinCode;
  final String hostProfileId;
  final String hostProfileName;
  final String hostShopName;
  final Map<String, dynamic> hostCharacter;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOpen;
  final int visitorCount;
  final List<OnlineCafeVisitorSummary> visitorSummaries;

  /// True when the session exists only on-device (Firebase unavailable).
  final bool isLocalFallback;

  Map<String, dynamic> toMap() {
    return {
      'sessionId': sessionId,
      'joinCode': joinCode,
      'hostProfileId': hostProfileId,
      'hostProfileName': hostProfileName,
      'hostShopName': hostShopName,
      'hostCharacter': hostCharacter,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isOpen': isOpen,
      'visitorCount': visitorCount,
      'visitors': {
        for (final visitor in visitorSummaries)
          visitor.profileId: visitor.toMap(),
      },
    };
  }

  factory OnlineCafeSession.fromMap(
    String sessionId,
    Map<String, dynamic> map,
  ) {
    final visitorsRaw = map['visitors'];
    final summaries = <OnlineCafeVisitorSummary>[];
    if (visitorsRaw is Map) {
      for (final entry in visitorsRaw.entries) {
        if (entry.value is Map) {
          summaries.add(
            OnlineCafeVisitorSummary.fromMap(
              Map<String, dynamic>.from(entry.value as Map),
            ),
          );
        }
      }
    }

    summaries.sort((a, b) => a.joinedAt.compareTo(b.joinedAt));

    return OnlineCafeSession(
      sessionId: _readString(map, 'sessionId') ?? sessionId,
      joinCode: _readString(map, 'joinCode') ?? '',
      hostProfileId: _readString(map, 'hostProfileId') ?? '',
      hostProfileName: _readString(map, 'hostProfileName') ?? 'Host',
      hostShopName: _readString(map, 'hostShopName') ?? 'Bearista\'s Shop',
      hostCharacter: map['hostCharacter'] is Map
          ? Map<String, dynamic>.from(map['hostCharacter'] as Map)
          : const {},
      createdAt: _readDateTime(map['createdAt']),
      updatedAt: _readDateTime(map['updatedAt']),
      isOpen: map['isOpen'] != false,
      visitorCount: _readInt(map, 'visitorCount', summaries.length),
      visitorSummaries: summaries,
    );
  }

  OnlineCafeSession copyWith({
    bool? isOpen,
    int? visitorCount,
    List<OnlineCafeVisitorSummary>? visitorSummaries,
    DateTime? updatedAt,
    bool? isLocalFallback,
  }) {
    return OnlineCafeSession(
      sessionId: sessionId,
      joinCode: joinCode,
      hostProfileId: hostProfileId,
      hostProfileName: hostProfileName,
      hostShopName: hostShopName,
      hostCharacter: hostCharacter,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isOpen: isOpen ?? this.isOpen,
      visitorCount: visitorCount ?? this.visitorCount,
      visitorSummaries: visitorSummaries ?? this.visitorSummaries,
      isLocalFallback: isLocalFallback ?? this.isLocalFallback,
    );
  }

  static String? _readString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
  }

  static int _readInt(Map<String, dynamic> map, String key, int fallback) {
    final value = map[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}

class OnlineCafeResult<T> {
  const OnlineCafeResult._({this.data, this.errorMessage});

  factory OnlineCafeResult.success(T data) {
    return OnlineCafeResult._(data: data);
  }

  factory OnlineCafeResult.failure(String message) {
    return OnlineCafeResult._(errorMessage: message);
  }

  final T? data;
  final String? errorMessage;

  bool get isSuccess => errorMessage == null;
}
