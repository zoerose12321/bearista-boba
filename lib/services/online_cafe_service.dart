import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/online_cafe_session.dart';
import '../models/player_profile.dart';
import 'firebase_bootstrap.dart';

/// Firestore-backed online café hosting and joining (v0.1.61+).
///
/// TODO: Add production Firestore security rules before public release.
class OnlineCafeService {
  OnlineCafeService({this._firestore});

  static const collectionName = 'onlineCafeSessions';
  static const joinCodeLength = 6;
  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final FirebaseFirestore? _firestore;
  final Random _random = Random();

  bool get isAvailable => FirebaseBootstrap.isReady;

  FirebaseFirestore get _db {
    final firestore = _firestore;
    if (firestore != null) {
      return firestore;
    }
    if (!FirebaseBootstrap.isReady) {
      throw StateError('Firebase is not initialized.');
    }
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection(collectionName);

  static String normalizeJoinCode(String raw) {
    return raw.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();
  }

  Future<OnlineCafeResult<OnlineCafeSession>> createCafeSession(
    PlayerProfile hostProfile,
  ) async {
    if (!isAvailable) {
      return OnlineCafeResult.failure(
        'Could not open café online. Check internet and Firebase setup.',
      );
    }

    try {
      await _closeOpenSessionsForHost(hostProfile.profileId);

      final now = DateTime.now();
      final sessionId = _collection.doc().id;
      final joinCode = await _generateUniqueJoinCode();
      final session = OnlineCafeSession(
        sessionId: sessionId,
        joinCode: joinCode,
        hostProfileId: hostProfile.profileId,
        hostProfileName: hostProfile.profileName,
        hostShopName: hostProfile.shopTitle,
        hostCharacter: hostProfile.toOnlineCharacterSummary(),
        createdAt: now,
        updatedAt: now,
        isOpen: true,
        visitorCount: 0,
        visitorSummaries: const [],
      );

      await _collection.doc(sessionId).set(session.toMap());
      return OnlineCafeResult.success(session);
    } catch (_) {
      return OnlineCafeResult.failure(
        'Could not open café online. Check internet and Firebase setup.',
      );
    }
  }

  Future<OnlineCafeResult<void>> closeCafeSession(String sessionId) async {
    if (!isAvailable) {
      return OnlineCafeResult.failure(
        'Could not close online café. Check internet and Firebase setup.',
      );
    }

    try {
      await _collection.doc(sessionId).update({
        'isOpen': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return OnlineCafeResult.success(null);
    } catch (_) {
      return OnlineCafeResult.failure(
        'Could not close online café. Check internet and Firebase setup.',
      );
    }
  }

  Future<OnlineCafeResult<OnlineCafeSession>> findSessionByJoinCode(
    String joinCode,
  ) async {
    if (!isAvailable) {
      return OnlineCafeResult.failure(
        'Could not find that café code. Check internet and Firebase setup.',
      );
    }

    final normalized = normalizeJoinCode(joinCode);
    if (normalized.length != joinCodeLength) {
      return OnlineCafeResult.failure('Could not find that café code.');
    }

    try {
      final snapshot = await _collection
          .where('joinCode', isEqualTo: normalized)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return OnlineCafeResult.failure('Could not find that café code.');
      }

      final doc = snapshot.docs.first;
      final session = OnlineCafeSession.fromMap(doc.id, doc.data());
      if (!session.isOpen) {
        return OnlineCafeResult.failure('Could not find that café code.');
      }

      return OnlineCafeResult.success(session);
    } catch (_) {
      return OnlineCafeResult.failure('Could not find that café code.');
    }
  }

  Future<OnlineCafeResult<OnlineCafeSession>> joinCafeSession({
    required String joinCode,
    required PlayerProfile visitorProfile,
  }) async {
    final lookup = await findSessionByJoinCode(joinCode);
    if (!lookup.isSuccess || lookup.data == null) {
      return lookup;
    }

    final session = lookup.data!;
    if (session.hostProfileId == visitorProfile.profileId) {
      return OnlineCafeResult.failure(
        'You are already hosting this café. Share the code with a friend.',
      );
    }

    try {
      final visitor = OnlineCafeVisitorSummary(
        profileId: visitorProfile.profileId,
        profileName: visitorProfile.profileName,
        shopTitle: visitorProfile.shopTitle,
        joinedAt: DateTime.now(),
      );

      await _collection.doc(session.sessionId).update({
        'visitors.${visitor.profileId}': visitor.toMap(),
        'visitorCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final refreshed = await _collection.doc(session.sessionId).get();
      if (!refreshed.exists) {
        return OnlineCafeResult.failure('Could not join that café code.');
      }

      return OnlineCafeResult.success(
        OnlineCafeSession.fromMap(session.sessionId, refreshed.data()!),
      );
    } catch (_) {
      return OnlineCafeResult.failure('Could not join that café code.');
    }
  }

  Future<OnlineCafeResult<void>> leaveCafeSession({
    required String sessionId,
    required String visitorProfileId,
  }) async {
    if (!isAvailable) {
      return OnlineCafeResult.success(null);
    }

    try {
      final doc = await _collection.doc(sessionId).get();
      if (!doc.exists) {
        return OnlineCafeResult.success(null);
      }

      final session = OnlineCafeSession.fromMap(sessionId, doc.data()!);
      final stillPresent = session.visitorSummaries.any(
        (visitor) => visitor.profileId == visitorProfileId,
      );

      if (!stillPresent) {
        return OnlineCafeResult.success(null);
      }

      await _collection.doc(sessionId).update({
        'visitors.$visitorProfileId': FieldValue.delete(),
        'visitorCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return OnlineCafeResult.success(null);
    } catch (_) {
      return OnlineCafeResult.success(null);
    }
  }

  Stream<OnlineCafeSession?> watchSession(String sessionId) {
    if (!isAvailable) {
      return Stream<OnlineCafeSession?>.value(null);
    }

    return _collection.doc(sessionId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return OnlineCafeSession.fromMap(sessionId, snapshot.data()!);
    });
  }

  Future<void> _closeOpenSessionsForHost(String hostProfileId) async {
    final snapshot = await _collection
        .where('hostProfileId', isEqualTo: hostProfileId)
        .get();

    for (final doc in snapshot.docs) {
      final session = OnlineCafeSession.fromMap(doc.id, doc.data());
      if (!session.isOpen) {
        continue;
      }
      await doc.reference.update({
        'isOpen': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<String> _generateUniqueJoinCode() async {
    for (var attempt = 0; attempt < 12; attempt++) {
      final code = _randomJoinCode();
      final existing = await _collection
          .where('joinCode', isEqualTo: code)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) {
        return code;
      }
      final session = OnlineCafeSession.fromMap(
        existing.docs.first.id,
        existing.docs.first.data(),
      );
      if (!session.isOpen) {
        return code;
      }
    }
    throw StateError('Could not generate a unique join code.');
  }

  String _randomJoinCode() {
    final buffer = StringBuffer();
    for (var i = 0; i < joinCodeLength; i++) {
      buffer.write(_codeChars[_random.nextInt(_codeChars.length)]);
    }
    return buffer.toString();
  }
}
