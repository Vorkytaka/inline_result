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

## ⁉️ Why does Result only catch Exceptions?

The problem is that dart error system not perfect, `Error` and `Exception` does not have single parent.
And since `Error` is a class that should [not be caught](https://api.flutter.dev/flutter/dart-core/Error-class.html), we decided to keep only `Exception`.

Feel free to implement `runErrorCatching` or `runObjectCatching` in your project and use it. 🔥

## ❤️ Contributing

If you have ideas, improvements, or just want to say `Result.success("hello!")`, feel free to open an issue or PR!