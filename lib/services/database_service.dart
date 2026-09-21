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

  static const String _invalidatedPath = 'invalidated_uuids';

  // ─── 投票番号の無効化関連メソッド ──────────────────────────────────

  /// 指定UUIDが無効化されているかチェック
  Future<bool> isUuidInvalidated(String uuid) async {
    try {
      final snapshot = await _database.ref('$_invalidatedPath/$uuid').get();
      return snapshot.exists;
    } catch (e) {
      print('無効化UUIDチェックエラー: $e');
      return false;
    }
  }

  /// 無効化されたすべてのUUID情報を取得
  Future<List<Map<String, dynamic>>> getInvalidatedUuids() async {
    try {
      final snapshot = await _database.ref(_invalidatedPath).get();
      if (!snapshot.exists || snapshot.value == null) {
        return [];
      }
      final data = snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> list = [];
      data.forEach((key, value) {
        if (value is Map) {
          list.add({
            'uuid': key.toString(),
            'invalidatedAt': value['invalidatedAt']?.toString() ?? '',
            'reason': value['reason']?.toString() ?? '理由なし',
            'hadVote': value['hadVote'] == true,
          });
        } else {
          list.add({
            'uuid': key.toString(),
            'invalidatedAt': '',
            'reason': '理由なし',
            'hadVote': false,
          });
        }
      });
      // 新しい順にソート
      list.sort((a, b) => (b['invalidatedAt'] ?? '').compareTo(a['invalidatedAt'] ?? ''));
      return list;
    } catch (e) {
      print('無効化UUID一覧取得エラー: $e');
      return [];
    }
  }

  /// 投票番号を無効化する（オプションで既存の投票データを削除）
  Future<bool> invalidateUuid(
    String uuid, {
    String? reason,
    bool deleteExistingVote = true,
  }) async {
    try {
      // 既存の投票データが存在するかチェック
      final voteSnapshot = await _database.ref('$_votesPath/$uuid').get();
      final bool hadVote = voteSnapshot.exists;

      // 無効化リストに登録
      await _database.ref('$_invalidatedPath/$uuid').set({
        'uuid': uuid,
        'invalidatedAt': DateTime.now().toIso8601String(),
        'reason': reason ?? '管理者による無効化',
        'hadVote': hadVote,
      });

      // 既存の投票データがあり、削除指定されている場合はvotesから削除
      if (hadVote && deleteExistingVote) {
        await _database.ref('$_votesPath/$uuid').remove();

        // ローカルキャッシュからも削除
        final prefs = await SharedPreferences.getInstance();
        final localVotes = prefs.getStringList('votes') ?? [];
        localVotes.removeWhere((voteJson) {
          try {
            final Map<String, dynamic> voteMap = json.decode(voteJson);
            return voteMap['uuid'] == uuid;
          } catch (_) {
            return false;
          }
        });
        await prefs.setStringList('votes', localVotes);
      }

      return true;
    } catch (e) {
      print('UUID無効化エラー: $e');
      return false;
    }
  }

  /// 無効化を解除（復元）する
  Future<bool> restoreUuid(String uuid) async {
    try {
      await _database.ref('$_invalidatedPath/$uuid').remove();
      return true;
    } catch (e) {
      print('UUID無効化解除エラー: $e');
      return false;
    }
  }

  /// UUIDの現在の状態を取得（'invalidated', 'voted', 'unused'）
  Future<String> checkUuidStatus(String uuid) async {
    try {
      final isInv = await isUuidInvalidated(uuid);
      if (isInv) return 'invalidated';

      final hasV = await hasVoted(uuid);
      if (hasV) return 'voted';

      return 'unused';
    } catch (e) {
      return 'unknown';
    }
  }
}

