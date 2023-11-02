import Foundation
import PropertyTracerSupport

@propertyWrapper
public struct Traced<P, V> {
    @_optimize(none)
    public var wrappedValue: V {
        get {
            let infos = Thread.callStackInfos(addresses: Thread.callStackReturnAddresses)
            // [0]: PropertyTracer.Traced.wrappedValue.getter
            // [1]: XXXX.getter

            handlePropertyAccess(
                accessor: .getter(ref.value),
                callStackInfos: infos
            )

            return ref.value
        }
        nonmutating set {
            let infos = Thread.callStackInfos(addresses: Thread.callStackReturnAddresses)
            // [0]: PropertyTracer.Traced.wrappedValue.setter
            // [1]: XXXX.setter

            handlePropertyAccess(
                accessor: .setter(
                    .init(currentValue: ref.value, newValue: newValue)
                ),
                callStackInfos: infos
            )

            ref.value = newValue
        }
    }

    public var projectedValue: Self { self }

    private let ref: Ref<V>

    public let parent: Ref<() -> P?>
    public let keyPath: Ref<() -> KeyPath<P, V>?>

    public var callback: Ref<((PropertyAccess<P, V>) -> Void)?>

    public init(
        wrappedValue: V,
        parent: @autoclosure @escaping () -> P? = nil,
        keyPath: @autoclosure @escaping () -> KeyPath<P, V>? = nil,
        _ callback: ((PropertyAccess<P, V>) -> Void)? = nil
    ) {
        ref = .init(value: wrappedValue)
        self.parent = .init(value: parent)
        self.keyPath = .init(value: keyPath)
        self.callback = .init(value: callback)
    }

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
            keyPath: keyPath.value()
        )

        print("[Access] ", terminator: "")
        if let keyPath = keyPath.value() {
            print("\(keyPath) ", terminator: "")
        }
        print("\(accessor.description)")
        print("         called from:", info.demangledSymbolName ?? "unknown")
        if let parent = parent.value() {
            print("         parent", parent)
        }

        callback.value?(access)
    }
}

extension Traced where P: AnyObject {
    public func setParent(_ parent: P) {
        self.parent.value = { [weak parent] in parent }
    }
}
extension Traced {
    @_disfavoredOverload
    public func setParent(_ parent: P) {
        self.parent.value = { parent }
    }

    public func setCallback(_ callBack: ((AnyPropertyAccess) -> Void)?) {
        self.callback.value = {
            callBack?(AnyPropertyAccess($0))
        }
    }
}

public class Ref<V> {
    public var value: V

    public init(value: V) {
        self.value = value
    }
}


extension Traced {
    public init(
        wrappedValue: V,
        _ callback: ((PropertyAccess<P, V>) -> Void)? = nil
    ) where P == Any {
        ref = .init(value: wrappedValue)
        self.parent = .init(value: { nil })
        self.keyPath = .init(value: { nil })
        self.callback = .init(value: callback)
    }
}

