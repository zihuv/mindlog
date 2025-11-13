import 'package:flutter_test/flutter_test.dart';
import 'package:mindlog/core/utils/tag_parser.dart';

void main() {
  group('TagParser Tests', () {
    test('extractTags should find single tag', () {
      const content = 'This is a #todo item';
      final tags = TagParser.extractTags(content);
      expect(tags, equals(['todo']));
    });

    test('extractTags should find multiple tags', () {
      const content = 'This is a #todo item with #urgent priority';
      final tags = TagParser.extractTags(content);
      expect(tags.toSet(), equals({'todo', 'urgent'}));
    });

    test('extractTags should handle tags with numbers, underscores, and hyphens', () {
      const content = 'Tags: #task_1, #bug-fix, #v2_launch';
      final tags = TagParser.extractTags(content);
      expect(tags.toSet(), equals({'task_1', 'bug-fix', 'v2_launch'}));
    });

    test('extractTags should ignore non-tag hashtags', () {
      const content = 'Hello # world and #123test';
      final tags = TagParser.extractTags(content);
      expect(tags, isEmpty);
    });

    test('extractTags should handle mixed case and normalize to lowercase', () {
      const content = 'Testing #Todo and #URGENT tags';
      final tags = TagParser.extractTags(content);
      expect(tags.toSet(), equals({'todo', 'urgent'}));
    });

    test('extractTags should handle multiple occurrences of same tag', () {
      const content = 'My #todo is important. This is another #todo.';
      final tags = TagParser.extractTags(content);
      expect(tags, equals(['todo'])); // Should be unique
    });

    test('extractTags should handle empty string', () {
      const content = '';
      final tags = TagParser.extractTags(content);
      expect(tags, isEmpty);
    });

    test('extractTags should handle content without tags', () {
      const content = 'This is just regular content without any tags';
      final tags = TagParser.extractTags(content);
      expect(tags, isEmpty);
    });

    test('formatTags should not change content without tags', () {
      const content = 'This is just regular content without any tags';
      final formatted = TagParser.formatTags(content);
      expect(formatted, equals(content));
    });
  });
}