import 'package:flutter/material.dart';

class MarkdownChecklist extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Function(String updatedText)? onTextChange;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final bool softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const MarkdownChecklist({
    super.key,
    required this.text,
    this.style,
    this.onTextChange,
    this.textAlign,
    this.textDirection,
    this.softWrap = true,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.locale,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
  });

  @override
  Widget build(BuildContext context) {
    // Parse the text to identify checklist items
    final parts = _parseMarkdownChecklists(text);

    // Create text spans for each part
    final textSpans = <TextSpan>[];

    for (final part in parts) {
      if (part.type == _PartType.text) {
        textSpans.add(TextSpan(text: part.content, style: style));
      } else if (part.type == _PartType.checklist) {
        final isChecked = part.isChecked!;
        final originalLine = part.originalLine!;

        // Extract the indentation and task content
        final match = RegExp(r'^(\s*)[-*]\s+\[([ xX])\]\s+(.+)$').firstMatch(originalLine);
        if (match == null) continue;

        // Use the current text style for sizing but override color for the checkbox
        final iconColor = style?.color ?? Theme.of(context).colorScheme.onSurface;
        final iconSize = (style?.fontSize ?? Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14.0) * 0.85;

        // Create the entire checklist item as a clickable widget
        textSpans.add(
          TextSpan(
            children: [
              WidgetSpan(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _toggleChecklistItem(part),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          // Add a container with proper padding to increase tap area
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                          child: Icon(
                            isChecked
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                            size: iconSize,
                            color: isChecked
                              ? Theme.of(context).colorScheme.primary
                              : iconColor,
                          ),
                        ),
                        Text(
                          ' ${match.group(3)!}',
                          style: style?.copyWith(
                            decoration: isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                alignment: PlaceholderAlignment.middle,
              ),
            ],
          ),
        );
      }
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: textSpans,
      ),
      textAlign: textAlign ?? TextAlign.start,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow ?? TextOverflow.clip,
      textScaler: textScaler ?? TextScaler.noScaling,
      maxLines: maxLines,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis ?? TextWidthBasis.parent,
      textHeightBehavior: textHeightBehavior,
    );
  }

  // Parse text to identify checklist items
  List<_TextPart> _parseMarkdownChecklists(String input) {
    final parts = <_TextPart>[];

    // Use regex to find markdown checklist items (supporting both - and * for lists)
    final checklistRegex = RegExp(r'^(\s*)[-*]\s+\[([ xX])\]\s+(.+)$', multiLine: true);
    final lines = input.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final match = checklistRegex.firstMatch(line);

      if (match != null) {
        // This is a checklist item
        final isChecked = match.group(2)!.trim().toLowerCase() == 'x';

        // Add the checklist part
        parts.add(_TextPart(
          type: _PartType.checklist,
          content: line,
          isChecked: isChecked,
          originalLine: line,
        ));
      } else {
        // This is regular text
        parts.add(_TextPart(
          type: _PartType.text,
          content: '$line${i < lines.length - 1 ? '\n' : ''}',
        ));
      }
    }

    // Consolidate consecutive text parts to preserve original formatting
    final consolidatedParts = <_TextPart>[];
    for (final part in parts) {
      if (part.type == _PartType.text &&
          consolidatedParts.isNotEmpty &&
          consolidatedParts.last.type == _PartType.text) {
        // Merge consecutive text parts
        final lastPart = consolidatedParts.removeLast();
        consolidatedParts.add(
          _TextPart(
            type: _PartType.text,
            content: lastPart.content! + part.content!,
          ),
        );
      } else {
        consolidatedParts.add(part);
      }
    }

    return consolidatedParts;
  }

  void _toggleChecklistItem(_TextPart checklistPart) {
    if (onTextChange != null) {
      // Update the original text by replacing exactly the checklist line that was toggled
      final newCheckStatus = checklistPart.isChecked! ? '[ ]' : '[x]';

      // Create the replacement by modifying the original line
      final originalLine = checklistPart.originalLine!;
      final updatedLine = originalLine.replaceFirst(
        RegExp(r'\[([ xX])\]'),
        newCheckStatus,
      );

      // Replace the original line with the updated line, ensuring we only change that specific line
      final newText = text.replaceFirst(originalLine, updatedLine);

      onTextChange!(newText);
    }
  }
}

enum _PartType { text, checklist }

class _TextPart {
  final _PartType type;
  final String? content;
  final bool? isChecked;
  final String? originalLine;

  _TextPart({
    required this.type,
    this.content,
    this.isChecked,
    this.originalLine,
  });
}