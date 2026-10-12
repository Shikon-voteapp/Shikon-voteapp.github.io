import 'dart:typed_data';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
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
  /// Loads the authoritative voting configuration from Firestore.
  static Future<void> loadRuntimeConfiguration() async {
    final period = await loadVotingPeriod();
    final groups = await loadGroups();
    if (period == null) throw StateError('Firestore に投票期間設定がありません。');
    if (groups.isEmpty) throw StateError('Firestore に投票団体がありません。');
    final categories = await loadVoteCategories(groups);
    if (categories.isEmpty) throw StateError('Firestore に投票カテゴリがありません。');
    defaultVotingPeriod = period;
    allGroups
      ..clear()
      ..addAll(groups);
    voteCategories
      ..clear()
      ..addAll(categories);
    final namesDoc =
        await _firestore.collection('app_config').doc('category_names').get();
    final names = Map<String, dynamic>.from(namesDoc.data()?['names'] ?? {});
    groupCategoryNames
      ..clear()
      ..addEntries(
        names.entries.map((entry) {
          final category = GroupCategory.values.firstWhere(
            (value) => value.name == entry.key,
            orElse: () => GroupCategory.other,
          );
          return MapEntry(category, entry.value.toString());
        }),
      );
    // Use cloud-provided labels when present; older projects may not have this
    // optional document yet. Fill missing labels from category metadata.
    for (final category in GroupCategory.values) {
      groupCategoryNames.putIfAbsent(
        category,
        () => switch (category) {
          GroupCategory.Tenji => '教室展示',
          GroupCategory.Moyoshi => '教室催し物',
          GroupCategory.Gakunen => '学年展示',
          GroupCategory.Roten => '露店',
          GroupCategory.Stage => '部活ステージ',
          GroupCategory.Performance => 'パフォーマンス',
          GroupCategory.Band => 'バンド',
          GroupCategory.other => 'その他',
        },
      );
    }
    final flowDoc =
        await _firestore
            .collection('app_config')
            .doc('student_verification')
            .get();
    final flow = flowDoc.data() ?? const <String, dynamic>{};
    studentVerification = VoteCategory(
      id: 'student_verification',
      name: flow['name'] ?? '投票券情報入力',
      description: flow['description'] ?? '投票券に記載されている番号を入力してください。',
      groups: const [],
    );
  }
  // VotingPeriodConfig
  // ─────────────────────────────────────────

  static Future<VotingPeriodConfig?> loadVotingPeriod() async {
    try {
      final doc =
          await _firestore.collection('app_config').doc('voting_period').get();
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

  static Future<void> saveRuntimeLabels() async {
    await _firestore.collection('app_config').doc('category_names').set({
      'names': {
        for (final entry in groupCategoryNames.entries)
          entry.key.name: entry.value,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _firestore.collection('app_config').doc('student_verification').set({
      'name': studentVerification.name,
      'description': studentVerification.description,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─────────────────────────────────────────
  // Groups
  // ─────────────────────────────────────────

  static Future<List<Group>> loadGroups() async {
    try {
      final snapshot =
          await _firestore.collection('groups').orderBy('order').get();
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.map((doc) {
        final data = doc.data();
        List<GroupCategory> categories = [];
        if (data['categories'] != null) {
          categories =
              (data['categories'] as List).map((c) {
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
      final snapshot =
          await _firestore.collection('vote_categories').orderBy('order').get();
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final legacyGroupIds = List<String>.from(data['groupIds'] ?? []);
        final eligibleCategories =
            (data['eligibleCategories'] as List?)
                ?.map(
                  (value) => GroupCategory.values.firstWhere(
                    (category) => category.name == value,
                    orElse: () => GroupCategory.other,
                  ),
                )
                .toList();
        final oldGroups =
            legacyGroupIds.isEmpty
                ? allGroups
                : allGroups
                    .where((g) => legacyGroupIds.contains(g.id))
                    .toList();
        return VoteCategory(
          id: doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          shortHelpText: data['shortHelpText'],
          helpUrl: data['helpUrl'],
          canSkip: data['canSkip'] ?? false,
          groups: allGroups,
          // New records include category filters; old group IDs are converted
          // to their current categories during load.
          eligibleCategories:
              eligibleCategories ??
              (legacyGroupIds.isEmpty
                  ? null
                  : GroupCategory.values
                      .where(
                        (category) => oldGroups.any(
                          (group) => group.hasCategory(category),
                        ),
                      )
                      .toList()),
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
        'eligibleCategories':
            cat.eligibleCategories?.map((c) => c.name).toList() ?? [],
        'order': i,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static Future<int> uploadBundledAssets({
    void Function(int, int)? onProgress,
  }) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final paths =
        manifest
            .listAssets()
            .where((path) => path.startsWith('assets/'))
            .toList();
    var uploaded = 0;
    for (final assetPath in paths) {
      final data = await rootBundle.load(assetPath);
      // Keep uploads under the path granted by the deployed Storage rules.
      final storagePath =
          'groups/legacy_assets/${assetPath.substring('assets/'.length)}';
      final ext = assetPath.split('.').last.toLowerCase();
      final contentType = switch (ext) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        'txt' => 'text/plain',
        _ => 'application/octet-stream',
      };
      await _storage
          .ref(storagePath)
          .putData(
            data.buffer.asUint8List(),
            SettableMetadata(contentType: contentType),
          );
      onProgress?.call(++uploaded, paths.length);
    }
    // Move configured group artwork references to the uploaded Storage objects.
    final uploadedPaths =
        paths
            .where(
              (path) => RegExp(
                r'\.(jpe?g|png|gif|webp)$',
                caseSensitive: false,
              ).hasMatch(path),
            )
            .map((path) => 'groups/legacy_assets/${path.substring('assets/'.length)}')
            .toSet();
    final groups = await loadGroups();
    final replacements = <String, Group>{};
    final updatedGroups =
        groups.map((group) {
          final basename =
              group.imagePath.replaceAll('\\', '/').split('/').last;
          final match =
              uploadedPaths
                  .where((path) => path.split('/').last == basename)
                  .firstOrNull;
          if (match == null) return group;
          final updated = Group(
            id: group.id,
            name: group.name,
            groupName: group.groupName,
            description: group.description,
            imagePath: match,
            floor: group.floor,
            pamphletPage: group.pamphletPage,
            categories: group.categories,
          );
          replacements[group.id] = updated;
          return updated;
        }).toList();
    await saveAllGroups(updatedGroups);
    allGroups
      ..clear()
      ..addAll(updatedGroups);
    for (final category in voteCategories) {
      category.groups
        ..clear()
        ..addAll(
          category.groups.map((group) => replacements[group.id] ?? group),
        );
    }
    return uploaded;
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
}
