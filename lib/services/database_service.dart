// services/database_service.dart
import '../models/group.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

class DatabaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final String _votesPath = 'votes';
  Future<bool> hasVoted(String uuid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localVotes = prefs.getStringList('votes') ?? [];

      for (var voteJson in localVotes) {
        Map<String, dynamic> voteMap = json.decode(voteJson);
        if (voteMap['uuid'] == uuid) {
          return true;
        }
      }
      final snapshot = await _database.ref('$_votesPath/$uuid').get();
      return snapshot.exists;
    } catch (e) {
      print('投票確認エラー: $e');
      return true;
    }
  }

  Future<bool> saveVote(Vote vote) async {
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
      await _database.ref('$_votesPath/${vote.uuid}').set(vote.toJson());
      return true;
    } catch (e) {
      print('投票保存エラー: $e');
      return false;
    }
  }

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

  Future<void> clearAllVotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('votes');
      await _database.ref(_votesPath).remove();
    } catch (e) {
      print('投票データクリアエラー: $e');
    }
  }

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

  Future<void> syncToFirebase() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localVotes = prefs.getStringList('votes') ?? [];

      for (var voteJson in localVotes) {
        Map<String, dynamic> voteMap = json.decode(voteJson);
        final snapshot =
            await _database.ref('$_votesPath/${voteMap['uuid']}').get();
        if (!snapshot.exists) {
          await _database.ref('$_votesPath/${voteMap['uuid']}').set(voteMap);
        }
      }
    } catch (e) {
      print('Firebaseへの同期エラー: $e');
    }
  }
}
