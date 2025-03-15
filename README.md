# Inline Result 🚀

Welcome to **Inline Result** – your new best friend for functional error handling in Flutter/Dart. If you're coming from Android and miss Kotlin's slick `Result` type, this package is here to save you from messy try/catch blocks and help you write safer, cleaner code.

This package brings a Kotlin-like `Result<T>` to Dart, using **extension types** for zero-cost wrapping.  

## ✨ Features

- ✅ **Functional Error Handling** – Chain transformations without losing control.
- ✅ **Zero-Cost Wrapping** – Uses Dart **extension types**, meaning no extra objects at runtime.
- ✅ **Familiar API** – Inspired by Kotlin's `Result<T>`, but Dart-friendly.
- ✅ **Safe & Readable** – No more `null` checks or exceptions hiding in logs.

## Why Inline Result?

Flutter/Dart lacks a built-in, functional way to handle errors like Kotlin. With Dart Result, you get a familiar and robust API to:

- **Avoid nested try/catch blocks**
- **Chain operations declaratively**
- **Embrace immutability and safer coding practices**

## ⚡ Quick Comparison: Kotlin vs Dart

### Kotlin

```kotlin
fun divide(a: Int, b: Int): Result<Int> {
    return runCatching { a / b }
}

val result = divide(10, 2)
    .map { it * 2 }
    .getOrElse { -1 }

println(result) // 10
```

### Dart

```dart
Result<int> divide(int a, int b) {
  return runCatching(() => a ~/ b);
}

final result = divide(10, 2)
    .map((value) => value * 2)
    .getOrElse((e, st) => -1);

print(result); // 10
```

## 🏗️ What’s Inlining & Why Should You Care?

Kotlin's `Result<T>` is an [inline class](https://kotlinlang.org/docs/inline-classes.html), meaning it avoids extra allocations while wrapping values.
Dart doesn’t have inline classes, but [extension types](https://dart.dev/language/extension-types) do something similar:

```dart
extension type Result<T>._(dynamic _value) { ... }
```

With this, your `Result<T>` **doesn’t create an extra object**—it’s just a wrapper at compile-time.
This means no **native performance** and **runtime overhead**. 🚀

## 🛠️ Usage Examples

### ✅ Basic Success & Failure

```dart
final success = Result.success("Yay!");
final failure = Result.failure(Exception("Oops!"));

print(success.getOrNull); // "Yay!"
print(failure.getOrNull); // null
```

### 🔗 Chaining with map and recover

```dart
final result = runCatching(() => int.parse("42"))
    .map((value) => value * 2)
    .recover((_) => 0);

print(result.getOrThrow); // 84
```

### 🔥 Handling Failures Gracefully

```dart
final result = runCatching(() => int.parse("NaN"))
    .getOrElse((e, st) => -1);

print(result); // -1
```

## 💤 Future Extensions

You can easily handle asynchronous operations with our `Future` extensions. Convert a `Future<T>` into a `Future<Result<T>>` to chain transformations and error handling without verbose try/catch blocks.
Or use `asyncRunCatching`.

Example:
```dart
Future<Result<Post>> fetchPost() {
  return http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts/1'))
      .asResult()
      .map(Post.fromJson);
}

Future<String> getCurrentTitle() {
  return fetchPost()
      .onFailure((exception, stacktrace) => print('$exception; $stacktrace'))
      .recover((_, __) => 'Something went wrong')
      .map((post) => post.title)
      .getOrThrow;
}
```

As you can see, we have repeated each extension method for `Future<Result<T>>` to make it easier for you to work with the results of asynchronous operations.

## ⁉️ Why does Result only catch Exceptions?

The problem is that dart error system not perfect, `Error` and `Exception` does not have single parent.
And since `Error` is a class that should [not be caught](https://api.flutter.dev/flutter/dart-core/Error-class.html), we decided to keep only `Exception`.

Feel free to implement `runErrorCatching` or `runObjectCatching` in your project and use it. 🔥

## ⏲️ Benchmarks

We conducted several benchmarks comparing three implementations of our `Result` type:

- **Inline Result**: Our extension type implementation.
- **Sealed with Extensions**: The sealed implementation using extension methods.
- **Sealed with Pattern Matching**: The sealed implementation that leverages in-place pattern matching.

| Method                       | Inline Result (us) | Sealed with Extensions (us) | Sealed with Pattern Matching (us) |
|------------------------------|-|-|-|
| getOrNull                    | 12.5148 | 81.8594 | 12.3652 |
| map | 12.3678 | 131.572 | 12.3636 |
| fold | 12.3604 | 91.9316 | 12.3607 |

### Key Observations

- **Inline Result** consistently shows excellent performance, matching the speed of the sealed implementation with in-place pattern matching.
- All benchmarks were executed using **const** constructors. Notably, removing const constructors only further degrades the performance of the sealed with extensions implementation.
- Benchmarks was run with AOT exe.

In summary, using inline classes provides the speed benefits of pattern matching while still offering convenient extension methods such as map, fold, and getOrNull.

## ❤️ Contributing

If you have ideas, improvements, or just want to say `Result.success("hello!")`, feel free to open an issue or PR!