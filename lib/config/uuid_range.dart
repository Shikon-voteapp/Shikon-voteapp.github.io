class UuidRange {
  final int start;
  final int end;

  UuidRange(this.start, this.end);

  bool contains(int uuid) {
    return uuid >= start && uuid <= end;
  }
}

class UuidRangeService {
  final List<UuidRange> _validRanges = [];

  UuidRangeService() {
    // 初期設定として有効なUUID範囲を追加

    addRange(1000000000, 9999999999);
  }

  // 範囲を追加するメソッド
  void addRange(int start, int end) {
    if (start <= end && start >= 0) {
      _validRanges.add(UuidRange(start, end));
    }
  }

  // 指定されたUUIDが有効な範囲内にあるかチェック
  bool isInValidRange(String uuidStr) {
    try {
      // 文字列をintに変換
      int uuid = int.parse(uuidStr);

      // いずれかの範囲に含まれていればtrue
      for (var range in _validRanges) {
        if (range.contains(uuid)) {
          return true;
        }
      }

      // どの範囲にも含まれていなければfalse
      return false;
    } catch (e) {
      // 数値変換エラーの場合はfalse
      print('UUID範囲チェックエラー: $e');
      return false;
    }
  }

  // 現在設定されている有効範囲のリストを取得
  List<UuidRange> get validRanges => List.unmodifiable(_validRanges);

  // 範囲をクリアするメソッド
  void clearRanges() {
    _validRanges.clear();
  }
}
