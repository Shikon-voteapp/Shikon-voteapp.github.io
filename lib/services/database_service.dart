// services/database_service.dart
import '../models/group.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// services/database_service.dart
import '../firebase_options.dart';
import '../models/group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 投票データを保存
  Future<void> saveVote(Vote vote) async {
    try {
      await _firestore.collection('votes').doc(vote.uuid).set(vote.toJson());
    } catch (e) {
      print('投票の保存中にエラーが発生しました: $e');
      throw e;
    }
  }

  // UUIDが既に投票済みかチェック
  Future<bool> hasVoted(String uuid) async {
    try {
      final doc = await _firestore.collection('votes').doc(uuid).get();
      return doc.exists;
    } catch (e) {
      print('投票チェック中にエラーが発生しました: $e');
      throw e;
    }
  }

  // 投票データの取得（管理画面用）
  Future<List<Vote>> getAllVotes() async {
    try {
      final snapshot = await _firestore.collection('votes').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Vote(
          uuid: doc.id,
          selections: Map<String, String>.from(data['selections']),
          timestamp: DateTime.parse(data['timestamp']),
        );
      }).toList();
    } catch (e) {
      print('投票データの取得中にエラーが発生しました: $e');
      throw e;
    }
  }

  // 投票集計データの取得
  Future<Map<String, Map<String, int>>> getVoteCounts() async {
    final votes = await getAllVotes();

    // カテゴリごとに集計 {カテゴリID: {団体ID: 票数}}
    Map<String, Map<String, int>> results = {};

    for (final vote in votes) {
      for (final entry in vote.selections.entries) {
        final categoryId = entry.key;
        final groupId = entry.value;

        if (!results.containsKey(categoryId)) {
          results[categoryId] = {};
        }

        if (!results[categoryId]!.containsKey(groupId)) {
          results[categoryId]![groupId] = 0;
        }

        results[categoryId]![groupId] =
            (results[categoryId]![groupId] ?? 0) + 1;
      }
    }

    return results;
  }
}
