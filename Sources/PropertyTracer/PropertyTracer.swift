import Foundation
import PropertyTracerSupport

/// A property wrapper for tracing access to a property.
///
/// This wrapper logs access to a property and can invoke a callback whenever the property is accessed.
/// It captures the call stack at the point of access to provide contextual information.
@propertyWrapper
public struct Traced<P, V> {
    @_optimize(none)
    public var wrappedValue: V {
        get {
            if isTraced.value {
                let infos = Thread.callStackInfos(addresses: Thread.callStackReturnAddresses)
                // [0]: PropertyTracer.Traced.wrappedValue.getter
                // [1]: XXXX.getter

                handlePropertyAccess(
                    accessor: .getter(ref.value),
                    callStackInfos: infos
                )
            }

            return ref.value
        }
        nonmutating set {
            if isTraced.value {
                let infos = Thread.callStackInfos(addresses: Thread.callStackReturnAddresses)
                // [0]: PropertyTracer.Traced.wrappedValue.setter
                // [1]: XXXX.setter

                handlePropertyAccess(
                    accessor: .setter(
                        .init(currentValue: ref.value, newValue: newValue)
                    ),
                    callStackInfos: infos
                )
            }

            ref.value = newValue
        }
    }

    public var projectedValue: Self { self }

    private let ref: Ref<V>

    public let parent: Ref<() -> P?>
    public let keyPath: Ref<KeyPath<P, V>?>

    public var callback: Ref<((PropertyAccess<P, V>) -> Void)?>

    private let isTraced: Ref<Bool> = .init(value: true)


    /// Creates a new traced property.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial value of the property.
    ///   - parent: An autoclosure that returns the parent object, if any.
    ///   - keyPath: An autoclosure that returns the key path to the property, if any.
    ///   - callback: A callback to invoke whenever the property is accessed.
    public init(
        wrappedValue: V,
        parent: @autoclosure @escaping () -> P? = nil,
        keyPath: KeyPath<P, V>? = nil,
        _ callback: ((PropertyAccess<P, V>) -> Void)? = nil
    ) {
        ref = .init(value: wrappedValue)
        self.parent = .init(value: parent)
        self.keyPath = .init(value: keyPath)
        self.callback = .init(value: callback)
    }

    /// Handles the property access, logging the access and invoking the callback if set.
    ///
    /// - Parameters:
    ///   - accessor: The type of access (getter or setter).
    ///   - callStackInfos: The call stack at the point of access.
    func handlePropertyAccess(
        accessor: PropertyAccess<P, V>.Accessor,
        callStackInfos: [CallStackInfo]
    ) {
        guard callStackInfos.count > 2 else { return }
        let info = callStackInfos[2]

        let access = PropertyAccess(
            accessor: accessor,
            callStackInfo: info,
            parent: parent.value(),
            keyPath: keyPath.value
        )

//        print("[Access] ", terminator: "")
//        if let keyPath = keyPath.value() {
//            print("\(keyPath) ", terminator: "")
//        }
//        print("\(accessor.description)")
//        print("         called from:", info.demangledSymbolName ?? "unknown")
//        if let parent = parent.value() {
//            print("         parent", parent)
//        }

        callback.value?(access)
    }
}

extension Traced where P: AnyObject {
    /// Sets the parent object for weak referencing.
    ///
    /// - Parameter parent: The parent object.
    public func setParent(_ parent: P) {
        self.parent.value = { [weak parent] in parent }
    }
}
extension Traced {
    /// Sets the parent object.
    ///
    /// - Parameter parent: The parent object.
    @_disfavoredOverload
    public func setParent(_ parent: P) {
        self.parent.value = { parent }
    }

    /// Sets the callback to be invoked on property access.
    ///
    /// - Parameter callBack: The callback.
    public func setCallback(_ callBack: ((AnyPropertyAccess) -> Void)?) {
        self.callback.value = {
            callBack?(AnyPropertyAccess($0))
        }
    }
}

/// A reference-holding class.
public class Ref<V> {

    /// The value held by the reference.
    public var value: V

    /// Creates a new reference.
    ///
    /// - Parameter value: The initial value.
    public init(value: V) {
        self.value = value
    }
}


extension Traced {
    // Creates a new traced property with a callback, without requiring a parent or key path.
    ///
    /// - Parameters:
    ///   - wrappedValue: The initial value of the property.
    ///   - callback: A callback to invoke whenever the property is accessed.
    ///
    /// Used for global variables, etc.
    /// Type P automatically specifies Any.
    public init(
        wrappedValue: V,
        _ callback: ((PropertyAccess<P, V>) -> Void)? = nil
    ) where P == Any {
        ref = .init(value: wrappedValue)
        self.parent = .init(value: { nil })
        self.keyPath = .init(value: nil)
        self.callback = .init(value: callback)
    }
}

extension Traced {
    /// Enable Tracing
    public func traced() {
        isTraced.value = true
    }

    /// Disable tracing
    public func untraced() {
        isTraced.value = false
    }
}

extension Traced {
    /// Get value without tracing
    public func untracedGet() -> V {
        let isTraced = isTraced.value

        untraced()

        let value = wrappedValue

        if isTraced {
            traced()
        }

        return value
    }

    /// Set value without tracing
    public func untracedSet(_ newValue: V) {
        let isTraced = isTraced.value

        untraced()

        wrappedValue = newValue

        if isTraced {
            traced()
        }
    }
}
