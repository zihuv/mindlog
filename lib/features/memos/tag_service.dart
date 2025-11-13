import 'package:mindlog/features/memos/memo_service.dart';
import 'package:mindlog/features/memos/domain/entities/memo.dart';

class TagService {
  static TagService? _instance;
  static TagService get instance {
    _instance ??= TagService();
    return _instance!;
  }

  /// Get all unique tags from all memos
  Future<List<String>> getAllTags() async {
    final memos = await MemoService.instance.getAllMemos();
    final allTags = <String>{};

    for (final memo in memos) {
      allTags.addAll(memo.tags);
    }

    // Sort tags alphabetically
    final sortedTags = allTags.toList();
    sortedTags.sort();

    return sortedTags;
  }

  /// Get memos that contain a specific tag
  Future<List<Memo>> getMemosByTag(String tagName) async {
    final memos = await MemoService.instance.getAllMemos();
    return memos.where((memo) => memo.tags.contains(tagName)).toList();
  }

  /// Get memos that match multiple tags (AND operation)
  Future<List<Memo>> getMemosByTags(List<String> tagNames) async {
    final memos = await MemoService.instance.getAllMemos();
    return memos.where((memo) {
      return tagNames.every((tag) => memo.tags.contains(tag));
    }).toList();
  }
}
