// services/database_service.dart
import '../models/group.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final String _votesPath = 'votes';

  // ローカルキャッシュと Firebase の両方でチェック
  Future<bool> hasVoted(String uuid) async {
    try {
      // ローカルチェック (オフライン対応用)
      final prefs = await SharedPreferences.getInstance();
      final localVotes = prefs.getStringList('votes') ?? [];

      for (var voteJson in localVotes) {
        Map<String, dynamic> voteMap = json.decode(voteJson);
        if (voteMap['uuid'] == uuid) {
          return true;
        }
      }

      // Firebase チェック
      final snapshot = await _database.ref('$_votesPath/$uuid').get();
      return snapshot.exists;
    } catch (e) {
      print('投票チェックエラー: $e');
      // エラーの場合は、安全のため投票済みとみなす
      return true;
    }
  }

  // 投票を保存し、Firebase と同期
  Future<bool> saveVote(Vote vote) async {
    try {
      // ローカルに保存
      final prefs = await SharedPreferences.getInstance();
      List<String> localVotes = prefs.getStringList('votes') ?? [];

      // 既存の投票をチェック
      bool exists = false;
      for (int i = 0; i < localVotes.length; i++) {
        Map<String, dynamic> voteMap = json.decode(localVotes[i]);
        if (voteMap['uuid'] == vote.uuid) {
          localVotes[i] = json.encode(vote.toJson());
          exists = true;
          break;
        }
      }

      // 新規投票の場合は追加
      if (!exists) {
        localVotes.add(json.encode(vote.toJson()));
      }

      await prefs.setStringList('votes', localVotes);

      // Firebase に同期
      await _database.ref('$_votesPath/${vote.uuid}').set(vote.toJson());

      return true;
    } catch (e) {
      print('投票保存エラー: $e');
      return false;
    }
  }

  // 投票データを取得（管理者用） - Firebase から取得
  Future<List<Vote>> getAllVotes() async {
    try {
      final snapshot = await _database.ref(_votesPath).get();

      if (!snapshot.exists) {
        return [];
      }

      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;
      List<Vote> votes = [];

      data.forEach((key, value) {
        Map<String, dynamic> voteMap = Map<String, dynamic>.from(value);
        votes.add(
          Vote(
            uuid: voteMap['uuid'],
            selections: Map<String, String>.from(voteMap['selections']),
            timestamp: DateTime.parse(voteMap['timestamp']),
          ),
        );
      });

      return votes;
    } catch (e) {
      print('投票データ取得エラー: $e');

      // Firebase 接続エラーの場合はローカルデータを返す
      final prefs = await SharedPreferences.getInstance();
      final localVotes = prefs.getStringList('votes') ?? [];

      return localVotes.map((voteJson) {
        Map<String, dynamic> voteMap = json.decode(voteJson);
        return Vote(
          uuid: voteMap['uuid'],
          selections: Map<String, String>.from(voteMap['selections']),
          timestamp: DateTime.parse(voteMap['timestamp']),
        );
      }).toList();
    }
  }

  // 全投票データをクリア（デモ/テスト用）
  Future<void> clearAllVotes() async {
    try {
      // ローカルデータをクリア
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('votes');

      // Firebase データをクリア
      await _database.ref(_votesPath).remove();
    } catch (e) {
      print('投票データクリアエラー: $e');
    }
  }

  // Firebase からローカルへデータ同期（アプリ起動時など）
  Future<void> syncFromFirebase() async {
    try {
      final snapshot = await _database.ref(_votesPath).get();

      if (!snapshot.exists) {
        return;
      }

      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;
      List<String> localVotes = [];

      data.forEach((key, value) {
        Map<String, dynamic> voteMap = Map<String, dynamic>.from(value);
        localVotes.add(json.encode(voteMap));
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('votes', localVotes);
    } catch (e) {
      print('Firebase同期エラー: $e');
    }
  }

  // オフライン時に保存された投票をFirebaseに同期
  Future<void> syncToFirebase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localVotes = prefs.getStringList('votes') ?? [];

      for (var voteJson in localVotes) {
        Map<String, dynamic> voteMap = json.decode(voteJson);

        // Firebase にデータが存在するか確認
        final snapshot =
            await _database.ref('$_votesPath/${voteMap['uuid']}').get();

        // 存在しない場合のみ同期
        if (!snapshot.exists) {
          await _database.ref('$_votesPath/${voteMap['uuid']}').set(voteMap);
        }
      }
    } catch (e) {
      print('Firebaseへの同期エラー: $e');
    }
  }
}
