// lib/config/uuid_range.dart
import 'valid_uuids.dart';

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
    _loadRangesFromUuidList(validUuids);
  }

  void addRange(int start, int end) {
    if (start <= end && start >= 0) {
      _validRanges.add(UuidRange(start, end));
    }
  }

  void _loadRangesFromUuidList(List<int> uuids) {
    if (uuids.isEmpty) return;

    final sortedUuids = uuids.toSet().toList()..sort();

    int? start;
    int? previous;

    for (final uuid in sortedUuids) {
      if (start == null) {
        start = uuid;
        previous = uuid;
      } else if (uuid == previous! + 1) {
        previous = uuid;
      } else {
        addRange(start, previous);
        start = uuid;
        previous = uuid;
      }
    }

    // 最後の範囲を追加
    if (start != null && previous != null) {
      addRange(start, previous);
    }
  }

  bool isInValidRange(String uuidStr) {
    try {
      int uuid = int.parse(uuidStr);
      return _validRanges.any((range) => range.contains(uuid));
    } catch (e) {
      print('UUID範囲チェックエラー: $e');
      return false;
    }
  }

  bool requiresStudentVerification(String uuidStr) {
    try {
      int uuid = int.parse(uuidStr);
      return uuid >= 2000000000 && uuid <= 2999999999;
    } catch (e) {
      print('学生検証範囲チェックエラー: $e');
      return false;
    }
  }

  List<UuidRange> get validRanges => List.unmodifiable(_validRanges);

  void clearRanges() {
    _validRanges.clear();
  }
}
