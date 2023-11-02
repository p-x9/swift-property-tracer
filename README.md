# PropertyTracer

Library for tracing access to properties.

<!-- # Badges -->

[![Github issues](https://img.shields.io/github/issues/p-x9/swift-property-tracer)](https://github.com/p-x9/swift-property-tracer/issues)
[![Github forks](https://img.shields.io/github/forks/p-x9/swift-property-tracer)](https://github.com/p-x9/swift-property-tracer/network/members)
[![Github stars](https://img.shields.io/github/stars/p-x9/swift-property-tracer)](https://github.com/p-x9/swift-property-tracer/stargazers)
[![Github top language](https://img.shields.io/github/languages/top/p-x9/swift-property-tracer)](https://github.com/p-x9/swift-property-tracer/)

The following information can be obtained:

- Accessor Type
  - get: current value
  - set: current & new value
- Call stack info
  - caller symbol name
  - caller symbol address
  - return address
- Parent object
- KeyPath
- ...

## Table of Contents

- [PropertyTracer](#propertytracer)
  - [Table of Contents](#table-of-contents)
  - [Usage](#usage)
    - [Single Property](#single-property)
      - [Additional Info](#additional-info)
      - [Get/Set values without tracing](#getset-values-without-tracing)
      - [Stop/ReStart tracing a property](#stoprestart-tracing-a-property)
    - [Trace all member properties of a certain type](#trace-all-member-properties-of-a-certain-type)
  - [License](#license)

## Usage

### Single Property

For example, when we define:

```swift
struct Item {
    @Traced(trace(_:_:))
    var title
}

func trace<P, V>(_ access: PropertyAccess<P, V>, _ tracedKeyPath: KeyPath<P, Traced<P, V>>?) {
    print("\n[Access]------------------")
    print("\(access.accessor.description)")
    print("called from: \(access.callStackInfo.demangledSymbolName ?? "unknown")")
    if let parent = access.parent {
        print("parent: \(parent)")
    }
    if let keyPath = access.keyPath {
        print("keyPath: \(keyPath)")
    }
    if let tracedKeyPath {
        print("tracedKeyPath: \(tracedKeyPath)")
    }
    print("----------------------------")
}
```

Suppose the following operation is performed:

```swift
let item = Item()
print(item.title)

item.title = "new value"

item.printTitle()
```

At this time, the specified `trace` function is called and the output is as follows:

```text
[Access]------------------
getter(String): initial value
called from: PropertyTracerTests.PropertyTracerTests.test() -> ()
----------------------------
initial value

[Access]------------------
setter(String): initial value => new value
called from: PropertyTracerTests.PropertyTracerTests.test() -> ()
----------------------------

[Access]------------------
getter(String): new value
called from: PropertyTracerTests.PropertyTracerTests.Item.printTitle() -> ()
----------------------------
new value
```

#### Additional Info

It is also possible to set up additional information to be received in the callback as follows:

```swift
struct Item {
    // specify parent and variable type
    @Traced<Item, String>(trace(_:_:))
    var title = "initial value"

    init(title: String = "initial value") {
        self.title = title

        // parent object
        _title.parent.value = copiedOwn

        // keyPath
        _title.keyPath.value = \Self.title

        // traced keyPath
        _title.tracedKeyPath.value = \Self._title
    }

    func printTitle() {
        print(title)
    }

    func copiedOwn() -> Self {
        let copied = self
        return self
    }
}
```

#### Get/Set values without tracing

For example, what would happen if you accessed the parent property directly in the `trace` function described above?

Accessing properties within the `trace` function will result in further calls to the `trace` function, leading to an infinite loop.

Therefore, there are methods that allow manipulation of values without tracing.

- get value without tracing

    ```swift
    let title = item._title.untracedGet()
    ```

- set value without tracing

    ```swift
    let newTitle = "new"
    item._title.untracedSet(newTitle)
    ```

#### Stop/ReStart tracing a property

- stop tracing

  ```swift
  item._title.untraced()
  ```

- restart taracing

  ```swift
  item._title.traced()
  ```

### Trace all member properties of a certain type

The following definition will cause all properties of type Item to be traced.

It is defined by a macro, and the `parent` and `keyPath` are set automatically.

Properties to which the `@NoTraced` attribute is attached are excluded from trace.

```swift
@PropertyTraced(trace(_:_:))
class ClassType1 {
    static let staticVar = ""
    var value1: String = "こんにちは"
    var value2: Int = 12

    @NoTraced
    var value3: Double = 1.0

    func modify() {
        value1 = "hello"
        value2 *= 2
        value3  = 14
    }
}

func trace(_ access: AnyPropertyAccess, _ tracedKeyPath: AnyKeyPath?) {
    print("\n[Access]------------------")
    print("\(access.accessor.description)")
    print("called from: \(access.callStackInfo.demangledSymbolName ?? "unknown")")
    if let parent = access.parent {
        print("parent: \(parent)")
    }
    if let keyPath = access.keyPath {
        print("keyPath: \(keyPath)")
    }
    if let tracedKeyPath {
        print("tracedKeyPath: \(tracedKeyPath)")
    }
    print("----------------------------")
}
```

## License

PropertyTracer is released under the MIT License. See [LICENSE](./LICENSE)
