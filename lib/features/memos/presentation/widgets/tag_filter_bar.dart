import 'package:flutter/material.dart';

class TagFilterBar extends StatefulWidget {
  final List<String> allTags;
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;
  final bool showLabel;

  const TagFilterBar({
    Key? key,
    required this.allTags,
    required this.selectedTags,
    required this.onTagsChanged,
    this.showLabel = true,
  }) : super(key: key);

  @override
  _TagFilterBarState createState() => _TagFilterBarState();
}

class _TagFilterBarState extends State<TagFilterBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLabel)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Filter by Tags',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          Container(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTagChip('All', !widget.selectedTags.isNotEmpty, () {
                  widget.onTagsChanged([]);
                }),
                const SizedBox(width: 8),
                ...widget.allTags.map(
                  (tag) =>
                      _buildTagChip(tag, widget.selectedTags.contains(tag), () {
                        final newSelectedTags = List<String>.from(
                          widget.selectedTags,
                        );
                        if (newSelectedTags.contains(tag)) {
                          newSelectedTags.remove(tag);
                        } else {
                          newSelectedTags.add(tag);
                        }
                        widget.onTagsChanged(newSelectedTags);
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(
          '#$tag',
          style: TextStyle(
            color: isSelected ? Colors.white : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.grey[300],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
