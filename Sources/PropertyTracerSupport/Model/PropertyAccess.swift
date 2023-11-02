//
//  CallerInfo.swift
//  
//
//  Created by p-x9 on 2023/10/31.
//  
//

import Foundation

/// A structure representing access to a property.
public struct PropertyAccess<P, V> {

    /// A structure representing changes to a property's value.
    public struct Changes {
        /// The current value of the property before the change.
        public let currentValue: V

        /// The new value that the property will change to.
        public let newValue: V

        /// Creates a new Changes instance.
        ///
        /// - Parameters:
        ///   - currentValue: The current value of the property.
        ///   - newValue: The new value that the property will change to.
        package init(
            currentValue: V,
            newValue: V
        ) {
            self.currentValue = currentValue
            self.newValue = newValue
        }
    }

    /// An enumeration representing the type of access (getter or setter).
    public enum Accessor {
        /// A case representing a getter access.
        case getter(V)

        /// A case representing a setter access.
        case setter(Changes)
    }

    /// The type of access.
    public let accessor: Accessor

    /// The call stack information at the point of access.
    public let callStackInfo: CallStackInfo

    /// The parent object containing the property, if available.
    public private(set) var parent: P?

    /// The key path to the property, if available.
    public private(set) var keyPath: KeyPath<P, V>?

    /// Creates a new PropertyAccess instance.
    ///
    /// - Parameters:
    ///   - accessor: The type of access.
    ///   - callStackInfo: The call stack information at the point of access.
    ///   - parent: The parent object containing the property.
    ///   - keyPath: The key path to the property.
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

/// A type-erased version of PropertyAccess.
public struct AnyPropertyAccess {

    /// A structure representing changes to a property's value in a type-erased manner.
    public struct Changes {
        /// The current value of the property before the change.
        public let currentValue: Any?

        /// The new value that the property will change to.
        public let newValue: Any?
    }

    /// An enumeration representing the type of access (getter or setter) in a type-erased manner.
    public enum Accessor {
        /// A case representing a getter access.
        case getter(Any?)

        /// A case representing a setter access.
        case setter(Changes)

        /// Creates a new Accessor instance from a typed `PropertyAccess<P, V>.Accessor` instance.
        ///
        /// - Parameter access: A typed `PropertyAccess<P, V>.Accessor` instance.
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

    /// The type of access in a type-erased manner.
    public let accessor: Accessor

    /// The call stack information at the point of access.
    public let callStackInfo: CallStackInfo

    /// The parent object containing the property, if available, in a type-erased manner.
    public private(set) var parent: Any?

    /// The key path to the property, if available, in a type-erased manner.
    public private(set) var keyPath: AnyKeyPath?

    /// Creates a new AnyPropertyAccess instance from a typed `PropertyAccess<P, V>` instance.
    ///
    /// - Parameter access: A typed `PropertyAccess<P, V>` instance.
    public init<P, V>(_ access: PropertyAccess<P, V>) {
        self.accessor = Accessor(access.accessor)
        self.callStackInfo = access.callStackInfo
        self.parent = access.parent
        self.keyPath = access.keyPath
    }
}

extension AnyPropertyAccess.Accessor: CustomStringConvertible {
    public var description: String {
        switch self {
        case .getter(let v):
            return "getter(\(type(of: v)): \(String(describing: v))"
        case .setter(let changes):
            return "setter(\(type(of: changes.newValue)): \(String(describing: changes.currentValue)) => \(String(describing: changes.newValue))"
        }
    }
}
