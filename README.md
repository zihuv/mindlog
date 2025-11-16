# MindLog

MindLog is a simple note-taking app with markdown support and tag functionality built with Flutter.

## Features

- Create, edit, and delete notes
- Markdown support with checkboxes
- Tag support - use #tagname to add tags to your notes
- Filter notes by tags using the tag filter bar
- Pin important notes
- Privacy settings for notes

## Tag Feature

- Add tags to your notes by including #tagname in the content
- Tags support letters, numbers, underscores, and hyphens (e.g., #todo, #urgent_task, #bug-fix)
- Notes with tags will display them below the content
- Filter notes by clicking on tags in the filter bar
- Tags are automatically extracted and reused across notes

## Building

To build the app:
```bash
flutter build apk --split-per-abi
```
Use: app-arm64-v8a-release.apk