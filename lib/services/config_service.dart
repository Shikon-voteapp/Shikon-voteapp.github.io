import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/group.dart' hide VoteCategory;
import '../models/vote_category.dart';
import '../config/vote_options.dart';

/// Firestore / Cloud Storage を通じた設定管理サービス
class ConfigService {
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;
  static final _auth = FirebaseAuth.instance;

  // ─────────────────────────────────────────
  // 管理者チェック
  // ─────────────────────────────────────────

  static Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _firestore.collection('admin_users').doc(user.uid).get();
    return doc.exists;
  }

  // ─────────────────────────────────────────
  // VotingPeriodConfig
  // ─────────────────────────────────────────

  static Future<VotingPeriodConfig?> loadVotingPeriod() async {
    try {
      final doc = await _firestore
          .collection('app_config')
          .doc('voting_period')
          .get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return VotingPeriodConfig(
        startDate: (data['startDate'] as Timestamp).toDate(),
        endDate: (data['endDate'] as Timestamp).toDate(),
        maintenanceEnabled: data['maintenanceEnabled'] ?? true,
        maintenanceStartHour: data['maintenanceStartHour'] ?? 1,
        maintenanceStartMinute: data['maintenanceStartMinute'] ?? 0,
        maintenanceEndHour: data['maintenanceEndHour'] ?? 2,
        maintenanceEndMinute: data['maintenanceEndMinute'] ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveVotingPeriod(VotingPeriodConfig config) async {
    await _firestore.collection('app_config').doc('voting_period').set({
      'startDate': Timestamp.fromDate(config.startDate),
      'endDate': Timestamp.fromDate(config.endDate),
      'maintenanceEnabled': config.maintenanceEnabled,
      'maintenanceStartHour': config.maintenanceStartHour,
      'maintenanceStartMinute': config.maintenanceStartMinute,
      'maintenanceEndHour': config.maintenanceEndHour,
      'maintenanceEndMinute': config.maintenanceEndMinute,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────
  // Groups
  // ─────────────────────────────────────────

  static Future<List<Group>> loadGroups() async {
    try {
      final snapshot = await _firestore
          .collection('groups')
          .orderBy('order')
          .get();
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.map((doc) {
        final data = doc.data();
        List<GroupCategory> categories = [];
        if (data['categories'] != null) {
          categories = (data['categories'] as List).map((c) {
            return GroupCategory.values.firstWhere(
              (e) => e.toString().split('.').last == c,
              orElse: () => GroupCategory.other,
            );
          }).toList();
        }
        return Group(
          id: doc.id,
          name: data['name'] ?? '',
          groupName: data['groupName'] ?? '',
          description: data['description'] ?? '',
          imagePath: data['imagePath'] ?? '',
          floor: data['floor'] ?? 1,
          pamphletPage: data['pamphletPage'],
          categories: categories,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveGroup(Group group, {required int order}) async {
    await _firestore.collection('groups').doc(group.id).set({
      'name': group.name,
      'groupName': group.groupName,
      'description': group.description,
      'imagePath': group.imagePath,
      'floor': group.floor,
      'pamphletPage': group.pamphletPage,
      'order': order,
      'categories':
          group.categories.map((c) => c.toString().split('.').last).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('groups').doc(groupId).delete();
  }

  /// 複数グループをバッチで一括保存（order も更新）
  static Future<void> saveAllGroups(List<Group> groups) async {
    final batch = _firestore.batch();
    for (int i = 0; i < groups.length; i++) {
      final ref = _firestore.collection('groups').doc(groups[i].id);
      batch.set(ref, {
        'name': groups[i].name,
        'groupName': groups[i].groupName,
        'description': groups[i].description,
        'imagePath': groups[i].imagePath,
        'floor': groups[i].floor,
        'pamphletPage': groups[i].pamphletPage,
        'order': i,
        'categories':
            groups[i].categories
                .map((c) => c.toString().split('.').last)
                .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  // ─────────────────────────────────────────
  // VoteCategories
  // ─────────────────────────────────────────

  static Future<List<VoteCategory>> loadVoteCategories(
    List<Group> allGroups,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('vote_categories')
          .orderBy('order')
          .get();
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final groupIds = List<String>.from(data['groupIds'] ?? []);
        final groups =
            allGroups.where((g) => groupIds.contains(g.id)).toList();
        return VoteCategory(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          shortHelpText: data['shortHelpText'],
          helpUrl: data['helpUrl'],
          canSkip: data['canSkip'] ?? false,
          groups: groups,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveAllVoteCategories(
    List<VoteCategory> categories,
  ) async {
    final batch = _firestore.batch();
    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final ref = _firestore.collection('vote_categories').doc(cat.id);
      batch.set(ref, {
        'name': cat.name,
        'description': cat.description,
        'shortHelpText': cat.shortHelpText ?? '',
        'helpUrl': cat.helpUrl ?? '',
        'canSkip': cat.canSkip,
        'groupIds': cat.groups.map((g) => g.id).toList(),
        'order': i,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static Future<void> deleteVoteCategory(String categoryId) async {
    await _firestore.collection('vote_categories').doc(categoryId).delete();
  }

  // ─────────────────────────────────────────
  // Image Upload / Delete
  // ─────────────────────────────────────────

  /// 画像をアップロードし、Storage パスを返す
  static Future<String> uploadGroupImage({
    required String groupId,
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    void Function(double)? onProgress,
  }) async {
    final ext = fileName.split('.').last.toLowerCase();
    final path = 'groups/$groupId/image.$ext';
    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(contentType: mimeType);
    final task = ref.putData(bytes, metadata);
    task.snapshotEvents.listen((snapshot) {
      if (onProgress != null && snapshot.totalBytes > 0) {
        onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });
    await task;
    return path; // Storage パスを返す（URLではない）
  }

  /// Storage パスからダウンロード URL を取得
  static Future<String> getDownloadUrl(String storagePath) async {
    final ref = _storage.ref().child(storagePath);
    return await ref.getDownloadURL();
  }

  /// Storage 内に保存されている全画像のパス一覧を取得
  static Future<List<String>> listUploadedImages() async {
    try {
      final ListResult result = await _storage.ref('groups').listAll();
      final List<String> paths = [];
      // groups/{groupId}/image.{ext}
      for (final prefix in result.prefixes) {
        final groupItems = await prefix.listAll();
        for (final item in groupItems.items) {
          paths.add(item.fullPath);
        }
      }
      for (final item in result.items) {
        paths.add(item.fullPath);
      }
      return paths;
    } catch (e) {
      return [];
    }
  }

  /// 全団体データを Firestore からクリア（初期化用）
  static Future<void> clearAllGroups() async {
    final snapshot = await _firestore.collection('groups').get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// 全賞データを Firestore からクリア（初期化用）
  static Future<void> clearAllCategories() async {
    final snapshot = await _firestore.collection('vote_categories').get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ─────────────────────────────────────────
  // Migration: vote_options.dart → Firestore
  // ─────────────────────────────────────────

  /// 既存データがない場合のみ vote_options.dart の内容を Firestore に投入する
  static Future<MigrationResult> migrateFromVoteOptions({
    required List<Group> sourceGroups,
    required List<VoteCategory> sourceCategories,
    required VotingPeriodConfig sourcePeriod,
    bool overwrite = false,
  }) async {
    int groupsAdded = 0;
    int categoriesAdded = 0;
    bool periodSet = false;

    // 投票期間
    final existingPeriod = await _firestore
        .collection('app_config')
        .doc('voting_period')
        .get();
    if (!existingPeriod.exists || overwrite) {
      await saveVotingPeriod(sourcePeriod);
      periodSet = true;
    }

    // 団体
    for (int i = 0; i < sourceGroups.length; i++) {
      final group = sourceGroups[i];
      final existing = await _firestore
          .collection('groups')
          .doc(group.id)
          .get();
      if (!existing.exists || overwrite) {
        await saveGroup(group, order: i);
        groupsAdded++;
      }
    }

    // 賞カテゴリ
    for (int i = 0; i < sourceCategories.length; i++) {
      final cat = sourceCategories[i];
      final existing = await _firestore
          .collection('vote_categories')
          .doc(cat.id)
          .get();
      if (!existing.exists || overwrite) {
        final ref = _firestore.collection('vote_categories').doc(cat.id);
        await ref.set({
          'name': cat.name,
          'description': cat.description,
          'shortHelpText': cat.shortHelpText ?? '',
          'helpUrl': cat.helpUrl ?? '',
          'canSkip': cat.canSkip,
          'groupIds': cat.groups.map((g) => g.id).toList(),
          'order': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        categoriesAdded++;
      }
    }

    return MigrationResult(
      groupsAdded: groupsAdded,
      categoriesAdded: categoriesAdded,
      periodSet: periodSet,
    );
  }
}

class MigrationResult {
  final int groupsAdded;
  final int categoriesAdded;
  final bool periodSet;

  const MigrationResult({
    required this.groupsAdded,
    required this.categoriesAdded,
    required this.periodSet,
  });

  @override
  String toString() =>
      '団体: $groupsAdded件, 賞: $categoriesAdded件, 投票期間: ${periodSet ? "設定済" : "スキップ"}';
}
