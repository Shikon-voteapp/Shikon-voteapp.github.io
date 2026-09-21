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
  static final List<UuidRange> _sharedValidRanges = _initRanges();
  final List<UuidRange> _validRanges;

  UuidRangeService() : _validRanges = _sharedValidRanges;

  static List<UuidRange> _initRanges() {
    final List<UuidRange> ranges = [];
    if (validUuids.isEmpty) return ranges;

    final sortedUuids = validUuids.toSet().toList()..sort();

    int? start;
    int? previous;

    for (final uuid in sortedUuids) {
      if (start == null) {
        start = uuid;
        previous = uuid;
      } else if (uuid == previous! + 1) {
        previous = uuid;
      } else {
        if (start <= previous && start >= 0) {
          ranges.add(UuidRange(start, previous));
        }
        start = uuid;
        previous = uuid;
      }
    }

    if (start != null && previous != null) {
      if (start <= previous && start >= 0) {
        ranges.add(UuidRange(start, previous));
      }
    }
    return ranges;
  }

  void addRange(int start, int end) {
    if (start <= end && start >= 0) {
      _validRanges.add(UuidRange(start, end));
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
