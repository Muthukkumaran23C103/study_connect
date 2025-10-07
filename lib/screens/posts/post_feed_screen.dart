# POST FEED SCREEN FIXES

## Fix these lines in lib/screens/posts/post_feed_screen.dart:

### Line 268: Replace
```dart
textController: titleController,
```
**With:**
```dart
controller: titleController,
```

### Line 274: Replace
```dart
textController: contentController,
```
**With:**
```dart
controller: contentController,
```

## COMPLETE CORRECTED SECTION:

Replace the entire dialog section (around lines 250-290) with this:

```dart
showDialog(
context: context,
builder: (BuildContext context) {
return AlertDialog(
title: const Text('Create New Post'),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
CustomTextField(
label: 'Title',
hintText: 'Enter post title',
controller: titleController, // ✅ CORRECT PARAMETER
),
const SizedBox(height: 16),
CustomTextField(
label: 'Content',
hintText: 'What would you like to share?',
controller: contentController, // ✅ CORRECT PARAMETER
),
],
),
actions: [
TextButton(
onPressed: () => Navigator.of(context).pop(),
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () async {
if (titleController.text.isNotEmpty &&
contentController.text.isNotEmpty) {
await context.read<PostProvider>().createPost(
title: titleController.text, // ✅ REQUIRED PARAMETER
content: contentController.text,
authorId: currentUser.id.toString(),
authorName: currentUser.displayName,
groupId: widget.groupId,
);
titleController.clear();
contentController.clear();
Navigator.of(context).pop();
}
},
child: const Text('Post'),
),
],
);
},
);
```