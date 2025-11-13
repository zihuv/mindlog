# MindLog

MindLog is a simple note-taking app with markdown support and tag functionality built with Flutter.

## Features

- Create, edit, and delete memos
- Markdown support with checkboxes
- Tag support - use #tagname to add tags to your memos
- Filter memos by tags using the tag filter bar
- Pin important memos
- Privacy settings for memos

## Tag Feature

- Add tags to your memos by including #tagname in the content
- Tags support letters, numbers, underscores, and hyphens (e.g., #todo, #urgent_task, #bug-fix)
- Memos with tags will display them below the content
- Filter memos by clicking on tags in the filter bar
- Tags are automatically extracted and reused across memos

## Building

To build the app:
```bash
flutter build apk --split-per-abi
```
Use: app-arm64-v8a-release.apk