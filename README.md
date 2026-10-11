# an_pager

A lightweight, flexible, and type-safe pagination model for Dart and Flutter applications.

`an_pager` provides unified, immutable pagination data structures supporting page-number based, total-count based, and key/cursor/token based pagination strategies.

---

## Features

- 📄 **`Pager<T>`**: Total-Page based pagination (`totalPage`).
- 🔢 **`Page<T>`**: Total-Count based pagination (`totalCount`).
- 🔑 **`KPage<T, Key>`**: Custom Key / Cursor / Token based pagination (Cursor-based).
- 🛠️ **Type-Safe & Immutable**: Built-in `generateNextPage`, `nextPageKey`, `hasNext`, `hasPrevious`, and `hasData` helpers.
- 🎯 **Zero Dependencies**: Pure Dart library with no external runtime dependencies.

---

## Getting Started

Add `an_pager` to your `pubspec.yaml`:

```yaml
dependencies:
  an_pager: ^1.0.0
```

Or run:

```bash
dart pub add an_pager
```

Then import it in your code:

```dart
import 'package:an_pager/an_pager.dart';
```

---

## Usage Examples

### 1. `Pager<T>` (Page-Based / 基于总页数)

Suitable for APIs that return `index`, `size`, and `totalPage`.

```dart
// 1. Initialize first page
var pager = Pager<String>.first(
  data: ['Item 1', 'Item 2'],
  size: 2,
  totalPage: 3,
);

print(pager.index);        // 1
print(pager.hasNext);      // true
print(pager.nextPageKey);  // (index: 2, size: 2)

// 2. Generate next page when data is loaded
if (pager.hasNext) {
  pager = pager.generateNextPage(['Item 3', 'Item 4']);
  print(pager.index);      // 2
}
```

### 2. `Page<T>` (Count-Based / 基于总条数)

Suitable for APIs that return `index`, `size`, and `totalCount`.

```dart
// Initialize first page with total count
var page = Page<String>.first(
  data: ['Product A', 'Product B'],
  size: 2,
  totalCount: 5,
);

print(page.hasNext); // true (1 * 2 < 5)

// Create Page instance from PageKey record (index: 2, size: 2)
final PageKey key = page.nextPageKey;
page = Page<String>.fromPageKey(
  data: ['Product C', 'Product D'],
  key: key,
  totalCount: 5,
);

print(page.index); // 2
```

### 3. `KPage<T, Key>` (Cursor / Key-Based / 基于游标)

Suitable for cursor or token-based pagination APIs (e.g. GraphQL, Firebase, Social Feed).

```dart
// Cursor-based pagination with String cursor
var kpage = KPage<String, String>.first(
  data: ['Post #100', 'Post #99'],
  hasNext: true,
  nextPageKey: 'cursor_99',
);

print(kpage.nextPageKey); // 'cursor_99'

// Generate next page with new cursor and status
if (kpage.hasNext) {
  kpage = kpage.generateNextPage(
    ['Post #98', 'Post #97'],
    hasNext: false, // Reached end
    nextPageKey: 'cursor_97',
  );
  print(kpage.hasNext); // false
}
```

You can also use custom objects or Records as `Key`:

```dart
final kpage = KPage<Item, ({int timestamp, String lastId})>.first(
  data: items,
  hasNext: true,
  nextPageKey: (timestamp: 1700000000, lastId: 'abc'),
);
```

---

## API Summary

| Class | Pagination Strategy | Key Type | Next Page Condition |
| :--- | :--- | :--- | :--- |
| **`Pager<T>`** | Total Pages (`totalPage`) | `PageKey` (`index`, `size`) | `index < totalPage` |
| **`Page<T>`** | Total Items (`totalCount`) | `PageKey` (`index`, `size`) | `index * size < totalCount` |
| **`KPage<T, Key>`** | Custom Key / Cursor | Custom `Key` | Explicit `hasNext` boolean |

---

## Issues

If you encounter issues, here are some tips for debug, if nothing helps report
to [issue tracker on GitHub](https://github.com/aymtools/an_pager/issues):
