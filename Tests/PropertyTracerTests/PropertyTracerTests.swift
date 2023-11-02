import XCTest
import PropertyTracer
@testable import PropertyTracerSupport

final class PropertyTracerTests: XCTestCase {
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

    @PropertyTraced(trace(_:_:))
    struct StructType1 {
        static let staticVar = ""
        var value1: String = "こんにちは"
        var value2: Int = 12

        @NoTraced
        var value3: Double = 1.0

        mutating func modify() {
            value1 = "hello"
            value2 *= 2
            value3  = 14
        }
    }

    func testClassType1() {
        let type = ClassType1()

        type.value1 = "おはよう"
        type.value2 = 5
        type.value3 = 3333

        type.modify()
    }

    func testStructType1() {
        var type = StructType1()

        type.value1 = "おはよう"
        type.value2 = 5
        type.value3 = 3333

        type.modify()
    }
}
extension PropertyTracerTests {
    class ClassType2 {
        @Traced(trace(_:tracedKeyPath:))
        var value1: String = "こんにちは"

        @Traced<ClassType2, Int>(trace(_:tracedKeyPath:))
        var value2: Int = 12

        @Traced<ClassType2, Double>(trace(_:tracedKeyPath:))
        var value3: Double = 1.0

        init() {
            _value2.keyPath.value = \Self.value2
            _value3.keyPath.value = \Self.value3

            _value3.parent.value = { [weak self] in self }

            _value3.tracedKeyPath.value = \Self._value3
        }

        func modify() {
            value1 = "hello"
            value2 *= 2
            value3  = 14
        }
    }

    struct StructType2 {
        @Traced(trace(_:tracedKeyPath:))
        var value1: String = "こんにちは"

        @Traced(keyPath: \Self.value2, trace(_:tracedKeyPath:))
        var value2: Int = 12

        @Traced(keyPath: \Self..value3, trace(_:tracedKeyPath:))
        var value3: Double = 1.0

        @Traced(keyPath: \Self.value3, trace(_:tracedKeyPath:))
        var value4: Double = 1.0

        init() {
            _value3.parent.value = copiedSelf
            _value3.tracedKeyPath.value = \Self._value3
        }

        mutating func modify() {
            value1 = "hello"
            value2 *= 2
            value3  = 14
        }

        func copiedSelf() -> Self {
            let copied = self
            return copied
        }
    }

    func testStructType2() {
        var type = StructType2()

        type.value1 = "おはよう"
        type.value2 = 5
        type.value3 = 3333

        type.modify()
    }

    func testClassType2() {
        let type = ClassType2()

        type.value1 = "おはよう"
        type.value2 = 5
        type.value3 = 3333

        type.modify()
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

func trace<P, V>(_ access: PropertyAccess<P, V>, tracedKeyPath: KeyPath<P, Traced<P, V>>?) {
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
