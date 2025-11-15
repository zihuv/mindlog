import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownWithCheckboxes extends StatelessWidget {
  final String data;
  final Map<int, bool> checklistStates;
  final Function(int, bool)? onCheckboxChanged;

  const MarkdownWithCheckboxes({
    Key? key,
    required this.data,
    required this.checklistStates,
    this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      builders: {
        'input': _TaskCheckboxBuilder(
          checklistStates: checklistStates,
          onChanged: onCheckboxChanged,
        ),
      },
    );
  }
}

class _TaskCheckboxBuilder extends MarkdownElementBuilder {
  final Map<int, bool> checklistStates;
  final Function(int, bool)? onChanged;

  _TaskCheckboxBuilder({required this.checklistStates, this.onChanged});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // Check if this is a task list item like [ ] or [x]
    final text = element.textContent;
    if (text.contains('[ ]') || text.contains('[x]') || text.contains('[X]')) {
      // Extract checkbox information
      final isChecked = text.contains('[x]') || text.contains('[X]');
      final index = _getCheckboxIndex(text, element);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0), // Minimal padding to match text line spacing
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Center-align checkbox with text
          children: [
            Checkbox(
              value: checklistStates[index] ?? isChecked,
              onChanged: (bool? value) {
                if (value != null) {
                  onChanged?.call(index, value);
                }
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target size
              visualDensity: VisualDensity.compact, // Reduce checkbox size
              shape: RoundedRectangleBorder( // Smaller checkbox shape
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4), // Better spacing to text
            Expanded(
              child: Text(
                _removeCheckboxSyntax(text),
                style: TextStyle(
                  fontSize: 14.0, // Match default text size
                  decoration: (checklistStates[index] ?? isChecked) ? TextDecoration.lineThrough : TextDecoration.none,
                  color: (checklistStates[index] ?? isChecked) 
                    ? Colors.grey // Use grey color for checked items
                    : null, // Use default color for unchecked items
                ),
              ),
            ),
          ],
        ),
      );
    }

    return null;
  }

  int _getCheckboxIndex(String text, md.Element element) {
    // This is a simplified approach - in a real app you'd want more sophisticated tracking
    // For now, we'll use the full text as a simple identifier
    return text.hashCode.abs();
  }

  String _removeCheckboxSyntax(String text) {
    return text
        .replaceAll(RegExp(r'\[ \]'), '')
        .replaceAll(RegExp(r'\[[xX]\]'), '')
        .trim();
  }
}

// Alternative implementation using custom syntax parsing to handle mixed content
class SimpleMarkdownCheckboxRenderer extends StatelessWidget {
  final String data;
  final Map<int, bool> checklistStates;
  final Function(int, bool)? onCheckboxChanged;

  const SimpleMarkdownCheckboxRenderer({
    Key? key,
    required this.data,
    required this.checklistStates,
    this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For now, keeping the line-by-line approach but making it more consistent
    // with proper styling for better visual integration
    final lines = data.split('\n');
    final List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (_isTaskListItem(line)) {
        final taskInfo = _parseTaskListItem(line, i);
        final isChecked = taskInfo.isChecked;
        final index = i; // Use line index as the key

        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0), // Minimal padding to match text line spacing
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Center-align checkbox with text
              children: [
                Checkbox(
                  value: checklistStates[index] ?? isChecked,
                  onChanged: (bool? value) {
                    if (value != null) {
                      onCheckboxChanged?.call(index, value);
                    }
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduce tap target size
                  visualDensity: VisualDensity.compact, // Reduce checkbox size
                  shape: RoundedRectangleBorder( // Smaller checkbox shape
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 4), // Better spacing to text
                Expanded(
                  child: Text(
                    taskInfo.content,
                    style: TextStyle(
                      fontSize: 14.0, // Match default text size
                      decoration: (checklistStates[index] ?? taskInfo.isChecked) ? TextDecoration.lineThrough : TextDecoration.none,
                      color: (checklistStates[index] ?? taskInfo.isChecked) 
                        ? Colors.grey // Use grey color for checked items
                        : null, // Use default color for unchecked items
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // For non-checklist lines, use a more integrated approach
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0), // Match checklist item spacing
            child: SelectableText(
              line,
              style: const TextStyle(fontSize: 14.0),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  bool _isTaskListItem(String line) {
    return RegExp(r'^\s*[\-\*]\s+\[([ xX])\]\s+.*').hasMatch(line);
  }

  _TaskInfo _parseTaskListItem(String line, int index) {
    final match = RegExp(r'^(\s*[\-\*]\s+)\[([ xX])\](.*)$').firstMatch(line);
    if (match != null) {
      final isChecked = match.group(2)!.trim().toLowerCase() == 'x';
      final content = match.group(3)!.trim();
      return _TaskInfo(isChecked, content);
    }
    return _TaskInfo(false, line);
  }
}

class _TaskInfo {
  final bool isChecked;
  final String content;

  _TaskInfo(this.isChecked, this.content);
}
