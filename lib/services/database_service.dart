// services/database_service.dart
import '../models/group.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DatabaseService {
  // 投票済みかどうかチェック
  Future<bool> hasVoted(String uuid) async {
    final prefs = await SharedPreferences.getInstance();
    final votes = prefs.getStringList('votes') ?? [];

    for (var voteJson in votes) {
      Map<String, dynamic> voteMap = json.decode(voteJson);
      if (voteMap['uuid'] == uuid) {
        return true;
      }
    }

    return false;
  }

  // 投票を保存
  Future<bool> saveVote(vote) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> votes = prefs.getStringList('votes') ?? [];

      // 既存の投票をチェック
      bool exists = false;
      for (int i = 0; i < votes.length; i++) {
        Map<String, dynamic> voteMap = json.decode(votes[i]);
        if (voteMap['uuid'] == vote.uuid) {
          votes[i] = json.encode(vote.toJson());
          exists = true;
          break;
        }
      }

      // 新規投票の場合は追加
      if (!exists) {
        votes.add(json.encode(vote.toJson()));
      }

      await prefs.setStringList('votes', votes);
      return true;
    } catch (e) {
      print('投票保存エラー: $e');
      return false;
    }
  }

  // 投票データを取得（管理者用）
  Future<List<Vote>> getAllVotes() async {
    final prefs = await SharedPreferences.getInstance();
    final votes = prefs.getStringList('votes') ?? [];

    return votes.map((voteJson) {
      Map<String, dynamic> voteMap = json.decode(voteJson);
      return Vote(
        uuid: voteMap['uuid'],
        selections: Map<String, String>.from(voteMap['selections']),
        timestamp: DateTime.parse(voteMap['timestamp']),
      );
    }).toList();
  }

  // 全投票データをクリア（デモ/テスト用）
  Future<void> clearAllVotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('votes');
  }
}
