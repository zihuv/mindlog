/// Utility class for parsing tags from content text
class TagParser {
  /// Extracts tags from content text in the format #tagname
  /// Supports tags starting with letters, and containing letters, numbers, underscores, and hyphens
  static List<String> extractTags(String content) {
    // Regular expression to match tags in the format #tagname
    // Must start with a letter, then can contain letters, numbers, underscores, and hyphens
    final tagRegex = RegExp(r'#([a-zA-Z][a-zA-Z0-9_\-]*)');
    final matches = tagRegex.allMatches(content);

    // Use a set to ensure uniqueness
    final tags = <String>{};
    for (final match in matches) {
      final tag = match
          .group(1)
          ?.toLowerCase(); // Convert to lowercase for consistency
      if (tag != null && tag.isNotEmpty) {
        tags.add(tag);
      }
    }

    return tags.toList();
  }

  /// Replaces tags in content with formatted version (for display purposes)
  static String formatTags(String content) {
    final tagRegex = RegExp(r'#([a-zA-Z0-9_\-]+)');
    return content.replaceAllMapped(tagRegex, (match) {
      final fullMatch = match[0]!;
      final tag = match.group(1);
      if (tag != null) {
        return '#$tag';
      }
      return fullMatch;
    });
  }
}
