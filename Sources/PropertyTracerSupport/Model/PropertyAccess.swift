//
//  CallerInfo.swift
//  
//
//  Created by p-x9 on 2023/10/31.
//  
//

import Foundation

public struct PropertyAccess<P, V> {
    public struct Changes {
        public let currentValue: V
        public let newValue: V

        package init(
            currentValue: V,
            newValue: V
        ) {
            self.currentValue = currentValue
            self.newValue = newValue
        }
    }

    public enum Accessor {
        case getter(V)
        case setter(Changes)
    }

    public let accessor: Accessor
    public let callStackInfo: CallStackInfo


    public private(set) var parent: P?
    public private(set) var keyPath: KeyPath<P, V>?

    package init(
        accessor: Accessor,
        callStackInfo: CallStackInfo,
        parent: P? = nil,
        keyPath: KeyPath<P, V>? = nil
    ) {
        self.accessor = accessor
        self.callStackInfo = callStackInfo
        self.parent = parent
        self.keyPath = keyPath
    }
}

extension PropertyAccess.Changes: Equatable where V: Equatable {}

extension PropertyAccess.Accessor: CustomStringConvertible {
    public var description: String {
        switch self {
        case .getter(let v):
            return "getter(\(V.self)): \(v)"
        case .setter(let changes):
            return "setter(\(V.self)): \(changes.currentValue) => \(changes.newValue)"
        }
    }
}

public struct AnyPropertyAccess {
    public struct Changes {
        public let currentValue: Any?
        public let newValue: Any?
    }

    public enum Accessor {
        case getter(Any?)
        case setter(Changes)

        init<P, V>(_ access: PropertyAccess<P, V>.Accessor) {
            switch access {
            case .getter(let v):
                self = .getter(v)
            case .setter(let changes):
                self = .setter(
                    .init(
                        currentValue: changes.currentValue,
                        newValue: changes.newValue
                    )
                )
            }
        }
    }

    public let accessor: Accessor
    public let callStackInfo: CallStackInfo

    public private(set) var parent: Any?
    public private(set) var keyPath: AnyKeyPath?

    public init<P, V>(_ access: PropertyAccess<P, V>) {
        self.accessor = Accessor(access.accessor)
        self.callStackInfo = access.callStackInfo
        self.parent = access.parent
        self.keyPath = access.keyPath
    }
}
