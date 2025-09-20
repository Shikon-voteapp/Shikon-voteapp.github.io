import '../models/group.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final String _votesPath = 'votes';
  Future<bool> hasVoted(String uuid) async {
    try {
      // まずローカルデータをチェック
      final prefs = await SharedPreferences.getInstance();
      final localVotes = prefs.getStringList('votes') ?? [];

      for (var voteJson in localVotes) {
        Map<String, dynamic> voteMap = json.decode(voteJson);
        if (voteMap['uuid'] == uuid) {
          return true;
        }
      }

      // ローカルにない場合はFirebaseで重複チェック（重複防止のため必要）
      final snapshot = await _database.ref('$_votesPath/$uuid').get();
      return snapshot.exists;
    } catch (e) {
      print('投票確認エラー: $e');
      // エラー時は安全側に倒して重複とみなす
      return true;
    }
  }

  Future<bool> saveVote(Vote vote) async {
    try {
      // クラウド優先：まずFirebaseに保存
      await _database.ref('$_votesPath/${vote.uuid}').set(vote.toJson());

      // 成功したらローカルにも保存（オフライン時のバックアップ用）
      final prefs = await SharedPreferences.getInstance();
      List<String> localVotes = prefs.getStringList('votes') ?? [];
      bool exists = false;
      for (int i = 0; i < localVotes.length; i++) {
        Map<String, dynamic> voteMap = json.decode(localVotes[i]);
        if (voteMap['uuid'] == vote.uuid) {
          localVotes[i] = json.encode(vote.toJson());
          exists = true;
          break;
        }
      }
      if (!exists) {
        localVotes.add(json.encode(vote.toJson()));
      }
      await prefs.setStringList('votes', localVotes);

      return true;
    } catch (e) {
      print('Firebase保存エラー: $e');
      // Firebase保存に失敗した場合のみローカルに保存
      try {
        final prefs = await SharedPreferences.getInstance();
        List<String> localVotes = prefs.getStringList('votes') ?? [];
        bool exists = false;
        for (int i = 0; i < localVotes.length; i++) {
          Map<String, dynamic> voteMap = json.decode(localVotes[i]);
          if (voteMap['uuid'] == vote.uuid) {
            localVotes[i] = json.encode(vote.toJson());
            exists = true;
            break;
          }
        }
        if (!exists) {
          localVotes.add(json.encode(vote.toJson()));
        }
        await prefs.setStringList('votes', localVotes);
        print('ローカルに保存しました（後で同期されます）');
        return true;
      } catch (localError) {
        print('ローカル保存もエラー: $localError');
        return false;
      }
    }
  }

  Future<List<Vote>> getAllVotes() async {
    try {
      // ローカルデータのみを返す（Firebaseアクセスを完全に回避）
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
    } catch (e) {
      print('投票データ取得エラー: $e');
      return [];
    }
  }

  Future<void> clearAllVotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('votes');
      await _database.ref(_votesPath).remove();
    } catch (e) {
      print('投票データクリアエラー: $e');
    }
  }

  // Firebaseからのデータ取得を無効化（転送量削減のため）
  Future<void> syncFromFirebase() async {
    // データ取得を抑制（ローカルデータのみ使用）
    print('Firebaseからのデータ取得は無効化されています');
  }

  Future<void> syncToFirebase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localVotes = prefs.getStringList('votes') ?? [];

      if (localVotes.isEmpty) {
        return;
      }

      // バッチでFirebaseに送信（一度に送信して転送量を削減）
      Map<String, dynamic> data = {};
      for (var voteJson in localVotes) {
        Map<String, dynamic> voteMap = json.decode(voteJson);
        data[voteMap['uuid']] = voteMap;
      }

      await _database.ref(_votesPath).set(data);
    } catch (e) {
      print('Firebaseへの同期エラー: $e');
    }
  }
}
